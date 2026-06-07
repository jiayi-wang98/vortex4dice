# DICE CGRA Core — Status & Integration Readiness

_Last indexed: 2026-06-05 · branch `dice_cgra_core_integration`_

> **Integration pass 1 done (2026-06-05):** the Mini_Dice backend glue has been
> ported in and `dice_core.sv` rewritten as a **flattened** backend (no
> dice_frontend/dice_backend/dice_cgra_rf/dice_cgra_subs wrappers). See
> **[Integration pass 1](#integration-pass-1--flattened-backend)** at the bottom for
> exactly what was wired vs. left as TODO.
>
> **Modularization done (2026-06-06):** the dense flat `dice_core.sv` has been
> split into a Mini_Dice-style hierarchy. See
> **[Modularization](#modularization-2026-06-06)** below.

## Modularization (2026-06-06)

`dice_core.sv` (was ~1100 lines of inline glue) is now a **thin 2-child top**
mirroring Mini_Dice. No logic changed — the inline `always`/`assign`/`generate`
blocks were lifted verbatim into modules; signal semantics and pipeline timing are
identical.

```
dice_core                         (thin: FE<->BE flat glue + dcache_mem_if adapt)
├─ dice_frontend                  cta_schedule_stage, fdr_top  (+ internal sched<->fdr ifaces)
└─ dice_backend                   (all-flattened, no interfaces)
   ├─ dice_eblock_tracker         single-eblock FSM / occupancy / accept / prog pulse
   ├─ dispatcher                  (unchanged)
   ├─ dice_mem_dispatch_credit    mem-port credit flow control (open+close loops together)
   ├─ dice_cgra_rf                RF + DORA fabric (dice_top) + launch + special regs + pred
   ├─ dice_brt                    (unchanged)
   ├─ dice_cgra_prog              cm0/cm1 -> bitstream serializer -> scanchain
   ├─ dice_tmcu_mem_edge          4x TMCU + VX_cache_4temporal (mem-side flattened)
   └─ dice_ldst_retire            coalesced load-response retire (tag -> RF wb + release)
```

Decisions taken (per the user): keep current flat dirs (no FE/BE folder move);
fuse RF+fabric+launch+special+pred under one `dice_cgra_rf`; flat wrappers (no
deep sub-leaves yet); `dice_ldst_retire` is its own module. `prog_pending` stays
in `dice_eblock_tracker` (shares the accept/exec FSM branch). The special-reg +
launch registers are deliberately kept **inside `dice_cgra_rf`** so they load on
the same `rf_rd_valid` edge — splitting them would silently break the fabric
operand/special-reg 1-cycle alignment.

Shared types added to `dice_pkg`: `DCACHE_*` tag-geometry params +
`dcache_outcmd_tag_t` (so the mem edge, retire, and wiring agree). `reshape_ld_dest`
is a small local helper in its two consumers (avoids a broad `DE_pkg` dependency).

**Verification (no VCS on this host — OS unsupported):**
- **verilator `--lint-only`** (per-module, blackboxing the SV-2017 interfaces it
  can't parse): all 6 leaf modules **and** `dice_backend` elaborate **clean**,
  including the full DORA fabric (`dice_top`) and the Vortex L1 cache — i.e. all
  backend port widths / connections check out.
- `dice_frontend` + `dice_core` use SV interfaces (verilator 4.036 can't parse the
  `interface foo import pkg::*; ()` header form) — verified instead by a structural
  port cross-check (every `dice_backend`/`dice_frontend` port is connected in
  `dice_core` with no missing/stray nets) + the interface code is verbatim from the
  previously-compiling flat `dice_core`.
- **xcelium** full elaboration is blocked by a **pre-existing** issue in Vortex's
  `VX_gpu_pkg.sv:62` (macro expands differently under xcelium's preprocessor →
  `EXPRPA`), which cascades `NOPBIND` into every package importer. This predates
  the refactor (the project builds under VCS) and is unrelated to the new modules;
  all errors in the new files are downstream of it.
- Lint-context note: a `bsg_defines.v -> bsg_defines.sv` symlink was added under
  `dora/.../basejump_stl/bsg_misc/` to resolve the `\`include "bsg_defines.v"`
  extension mismatch (the old filelist TODO). Harmless; also helps the VCS build.

Carried-over TODOs are unchanged by this refactor (store-retire, per-slice
blockIdx, const_data source, `dcache_mem_if` TB wiring, 2/4-way unroll).

This document tracks the state of the DICE CGRA core (`dice_new/`) that replaces the
standard Vortex shader core (SM), and the work remaining before it can be integrated
into the Vortex GPGPU. Based on the work in https://arxiv.org/pdf/2605.05496. The
reconfigurable CGRA fabric itself lives in the separate **dora** repo.

## TL;DR

The individual pipeline-stage modules are largely built and unit-tested (frontend
scheduling, SIMT stack, dispatcher, register file, the hand-written 4×4 CGRA fabric,
coalescing unit, commit table all exist). The blocker is **integration**: the
top-level `dice_core.sv` is a half-wired skeleton — the CGRA execution unit, the
load/store path, and the commit table are **not instantiated or are commented out**,
the write-back loop is open, and **`dice_core` is not instantiated anywhere in the
Vortex hierarchy yet (0% socket integration)**. Branch handling is a deliberate
`no_branches` stub, so only straight-line kernels run today.

Roughly: **~85% of the parts are on the bench, ~20% of the assembly is done.**

> **Big shortcut available:** the **Mini_Dice** repo (`/data/amanoj3/Mini_Dice`, a
> defeatured fork of the same DICE lineage) is the *already-assembled* version — it
> wires `dice_core → dice_frontend + dice_backend`, closes the CGRA write-back loop,
> instantiates the DORA fabric, and has a real branch handler. Much of the P0/P1
> "integration glue" below can be ported instead of written from scratch. See
> **[Reuse from Mini_Dice](#reuse-from-mini_dice)**. Items it solves are tagged
> **[Mini_Dice ✓]**.

---

## Pipeline stage-by-stage

| Stage | Module(s) | State | Verdict |
|---|---|---|---|
| **CTA Schedule** | `cta_schedule/*` (controller, scheduler, active/status tables, SIMT stack + controller) | **COMPLETE** & unit-tested. Full SIMT divergence FSM exists. | ✅ Solid |
| **Fetch/Decode/Read (FDR)** | `fetch_stage/*` (fdr_top, meta_fetch, decode, bitstream_fetch_load, valid_check) | **COMPLETE** *except* branch handling | ⚠️ |
| → Branch handler | `branch_handler_no_branches.sv` | **STUB by design** — asserts `branch_ena==0`, no divergence/prefetch/flush. Barrier & prefetch-clear hardcoded in `fdr_top` (lines 211–212). | ❌ Straight-line only |
| **Dispatcher** | `dispatcher/dispatcher_refactor/*` + scoreboards + thread logic | **COMPLETE** & unit-tested (refactored, parameterized). WB path *internally* wired. | ✅ but WB port open at top |
| **Register File** | `cgra_subsystem/regfile/*` | **PARTIAL** — read/write/special-reg work; gaps: 2/4-way unroll read (`dice_read_org.sv`), write-unroll uses only TID[0], missing `v_o` valid output (`dice_rf_ctrl.sv`), read-forwarding TODOs, ASIC SRAM is a **stub** (`sram_stub.v`). | ⚠️ Functional for 1-way sim |
| **CGRA Execution** | `cgra_subsystem/dice_cgra_subsystem.sv`, `dice_cgra` (4×4), `dice_tile`, `dice_pe`, generated ALU + routers | Subsystem & fabric **COMPLETE in isolation** (unit TB passes) but **NOT instantiated** in `dice_core`. A `dummy_cgra.sv` placeholder exists instead. | ❌ Not wired |
| **Load/Store** | `ldst_unit/*` (temporal_coalescing_unit, coalesce_buffer, VX_cache_with_temporal, smem) | Coalescing unit PARTIAL→usable; **entirely commented out** in `dice_core` (lines ~187–221). `smem` sim-only w/ inverted write-mask bug. | ❌ Commented out |
| **Commit** | `commit_stage/block_commit_table.sv` | Module **COMPLETE**, but **commented out** in `dice_core` (lines ~226–242); its pop→scheduler `eblock_commit_*` ports are tied to `()`. | ❌ Commented out |
| **Memory IF** | `VX_mem_bus_if` (metacache + bitstream cache) | Interfaces defined & passed into FDR; **not connected to ldst or Vortex memory hierarchy**. | ⚠️ |

---

## Critical integration gaps (in `dice_core.sv`)

1. **CGRA never instantiated.** `cgra_v_lo / cgra_data_lo / cgra_tid_lo` are declared
   (lines 51–53) but **undriven** — they feed the RF write port from nothing.
   `dice_cgra_subsystem` must be instantiated and fed from `fdr_out_if` metadata.
2. **Write-back loop open.** Dispatcher `.wb_valid()` / `.wb_tid_bitmap()` are empty
   (lines 111–112) and `.dispatch_fifo_pop('1)` is hardcoded. Scoreboards never get
   released by real CGRA completion.
3. **Load/store unit commented out** — no address/size/write-enable source from the
   CGRA exists yet.
4. **Commit table commented out** — `eblock_commit_valid/id` into the scheduler are
   dangling, so CTAs can't retire through the intended path.
5. **`dice_core` is not in the Vortex tree.** `grep dice_core hw/` → nothing.
   `VX_socket.sv:219–251` still instantiates `VX_core`. No adapter exists to bridge
   Vortex's `dcr_bus/icache/dcache` model to DICE's `cta_dispatch_if/cta_complete_if`
   + dual metacache/bitstream caches.

---

## Action items

### P0 — Close the intra-core loop (makes `dice_core` a functioning unit)
- [ ] **[Mini_Dice ✓]** **Instantiate `dice_cgra_subsystem` in `dice_core.sv`**; drive
      it from `fdr_out_if` (unrolling_factor, in/out_regs_bitmap, ld_dest_regs) and the
      RF read data. Remove `dummy_cgra` reliance. _Mini_Dice does this via
      `dice_cgra_rf` + `dice_cgra_subs` (which wraps the DORA `dice_top`)._
- [ ] **[Mini_Dice ✓]** **Wire the write-back loop:** CGRA completion →
      `cgra_v_lo/tid_lo/data_lo` → RF write port **and** → dispatcher
      `wb_valid/wb_tid_bitmap`. Replace hardcoded `dispatch_fifo_pop('1)` with real
      CGRA-ready backpressure. _Mini_Dice's `dice_backend.sv` is the reference: it
      derives `wb_*` from the memory response and tracks a CGRA pipeline-count for
      backpressure._
- [ ] **[Mini_Dice ✓]** **Add the RF `v_o` valid output** (`dice_rf_ctrl.sv` TODO) so
      CGRA knows when operands are ready (`rf_rd_valid & disp_valid`). _Present in
      Mini_Dice's `dice_cgra_rf`._
- [ ] **Uncomment + wire the `temporal_coalescing_unit`**; define where load/store
      **address, size, write-enable, ld_dest_reg, block_id** come from (unresolved —
      the CGRA/ISA must emit them; see open questions). _Note: Mini_Dice uses a
      different ldst approach (`mem_req_fifo` over AXI-Lite, no temporal coalescing),
      so the **control/sequencing** is reusable but the **memory edge is not** — keep
      `dice_new`'s coalescing unit + `VX_mem_bus_if`._
- [ ] **[Mini_Dice ✓]** **Uncomment + wire `block_commit_table`**: insert on eblock
      fire, update on ldst completion, connect `pop_*` → scheduler `eblock_commit_*`
      (currently `()`). _Mini_Dice's `dice_brt.sv` is the wired version (insert pending
      reads/stores, retire on load/store/exec pop, commit out to frontend)._

### P1 — Register file completeness
- [ ] Implement **2-way / 4-way unrolling** read path (`dice_read_org.sv`) and
      **write-unroll** (currently only `cgra_tid_i[0]`) in `dice_rf_ctrl.sv`.
- [ ] **[Mini_Dice ✓]** Add the **output-register-bitmap shift register**
      (`dice_core.sv:155` TODO). _Mini_Dice's `dice_shift_reg.sv` is a drop-in,
      parameterized ring-buffer latency shift reg._
- [ ] Implement RF **read-forwarding** (`reg_wr_buffer.sv`, `reg_wr_single_entry.sv`) —
      perf, not correctness.

### P1 — Branch / control flow (currently disabled)
- [ ] **[Mini_Dice ✓]** Replace `branch_handler_no_branches.sv` with a **real branch
      handler**: divergence detection, prefetch-block gen, flush generation,
      branch-target handling. (SIMT-stack infra already exists downstream — it's just
      never driven.) _Mini_Dice has a full `branch_handler.sv` (363 lines); port the
      logic, reconcile the interface._
- [ ] Implement **barrier completion** and **prefetch-clear** (un-hardcode
      `fdr_top.sv:211–212`).
- [ ] Add the meta_fetch ready-stall / branch-handler-done gating (TODOs at
      `meta_fetch.sv:1–8`).

### P2 — Fabric source-of-truth & memory
- [ ] **Decide: hand-written `dice_cgra` vs. DORA-generated fabric.** DORA
      (`/data/amanoj3/dora`) already generates a full DICE fabric
      (`examples/devices/dice-isca/.../build/rtl/dice_top.sv`, 43 files) with
      **scanchain bitstream loading** — but the in-repo fabric uses a flat
      `cgra_cfg[2496-bit]` static config. Two different config models; pick one. If
      DORA, write an adapter and switch the bitstream loader from static pins to
      scanchain.
- [ ] Replace ASIC `sram_512x32` **stub** with a real compiled macro (blocks ASIC
      synth only; sim/FPGA fine).
- [ ] Fix `smem.sv` write-mask inversion bug and make it synthesizable, if shared
      memory is in scope.

### P2 — Verification
- [ ] Build a **full intra-core end-to-end test**: dispatch → schedule → FDR → CGRA
      execute → RF write-back → commit → `cta_complete`. Today only **per-stage** TBs
      exist; there is **no end-to-end drain test**.
- [ ] Cover 2/4-TID dispatch and back-pressure/stall scenarios (existing TBs are
      happy-path).

### P3 — Vortex integration (separate, after the core closes)
- [ ] Write a **`VX_dice_adapter`**: map Vortex `dcr_bus/icache/dcache` ↔ DICE
      `cta_dispatch_if/cta_complete_if` + metacache/bitstream caches; connect the DICE
      memory buses to the L1/L2 hierarchy.
- [ ] Instantiate the adapter in `VX_socket.sv` (behind `ifdef USE_DICE_CORE`), wire
      the host-side CTA dispatcher.
- [ ] Socket/cluster-level integration test.

---

## Open architectural questions (need a human decision)

1. **Load/store interface:** where do memory address/size/write-enable originate from
   the CGRA fabric? Undefined, and blocks the entire ldst + commit wiring.
2. **Fabric config model:** in-repo flat `cgra_cfg` vs. DORA scanchain — which is the
   real target? _**Mini_Dice picked DORA scanchain**: it wraps the DORA-generated
   `dice_top` with a serial loader (`cgra_bitstream_buf_serial.sv`,
   `prog_din/prog_dout`). If `dice_new` follows suit, the flat `cgra_cfg`/`dice_cgra`
   path is superseded._
3. **Branch support scope:** is straight-line-only acceptable for first integration, or
   is the real branch handler in scope now? _Mini_Dice ships a real `branch_handler.sv`,
   so the logic exists either way._

---

## Key parameters (from `dice_config.vh` / `dice_pkg.sv`)

| Parameter | Value | Notes |
|---|---|---|
| `DICE_NUM_MAX_THREADS_PER_CORE` | 512 | Max threads per CTA |
| `DICE_NUM_MAX_CTA_PER_CORE` | 4 | Max concurrent CTAs |
| `DICE_GPR_NUM` / `DICE_PR_NUM` / `DICE_CR_NUM` | 16 / 8 / 8 | GPR / predicate / constant regs |
| `DICE_NUM_BANKS` | 32 | RF banks |
| `DICE_REG_DATA_WIDTH` / `DICE_ADDR_WIDTH` | 32 / 32 | |
| `DICE_METADATA_WIDTH` | 256 | Matches L1 line |
| `DICE_BITSTREAM_SIZE` | 2048 | 256 bytes max bitstream |
| `DICE_SIMT_STACK_DEPTH` | 32 | |
| CGRA config | 4×4 tiles, 156 bits/tile = 2496 bits | hand-written fabric |

---

## Known TODO/FIXME markers in RTL

| File | Note |
|---|---|
| `dice_core.sv:155` | add shift reg for `out_regs_bitmap` |
| `cgra_subsystem/regfile/dice_rf_ctrl.sv` | add `v_o` valid signal for CGRA |
| `cgra_subsystem/regfile/dice_read_org.sv` | implement 2-TID / 4-TID read cases |
| `cgra_subsystem/regfile/reg_wr_buffer.sv` | implement read forwarding |
| `cgra_subsystem/regfile/reg_wr_single_entry.sv` | implement read forwarding |
| `cgra_subsystem/regfile/sram_stub.v` | ASIC SRAM macro is an empty stub |
| `dice_ram/dice_ram_1w1r.sv` | add FP45 SRAM compiler macro |
| `cta_schedule/active_cta_table.sv` | track true active-thread count, not just hw_cta_size |
| `fetch_stage/meta_fetch.sv:1–8` | ready-stall + branch-handler-done gating |

---

## Reuse from Mini_Dice

`/data/amanoj3/Mini_Dice` (`github.com/aadithyamanoj/Mini_Dice`) is a **separate fork of
the same DICE lineage** — same `dispatcher_refactor/`, `cta_schedule/`, `regfile/`,
`fdr_top`, same packages. The difference is that **Mini_Dice is the *integrated*
version**: it has a wired `dice_core → dice_frontend + dice_backend`, the CGRA actually
instantiated, the write-back loop closed, and the DORA fabric (`dice_top`) wired in with
a serial scanchain loader. That is exactly the assembly `dice_new` is missing.

### Guiding principle: lift the glue, re-implement the internals

Mini_Dice's value is the **inter-module glue and wiring** — how the backend modules are
connected, the handshakes, and especially the **cross-backend in-flight tracking needed
for correct retirement**. The **fundamental implementations of the modules themselves may
be drastically different** in full DICE. Port the structure and control logic; expect to
rewrite the datapath internals. Do **not** assume a 🟢 module is a verbatim drop-in
unless this doc says so.

### Mini_Dice → full DICE: what actually differs

1. **Single-CTA → multi-CTA.** Mini_Dice is `DICE_NUM_MAX_CTA_PER_CORE=1`, so it largely
   ignores CTA identity. Full DICE (4 CTAs/core) needs **correct `CTA_ID` tracking
   threaded through the backend** — dispatcher, scoreboard, RF addressing, BRT/commit,
   and the CGRA pipeline bookkeeping all have to carry and disambiguate CTA id. This is
   net-new work on top of the lifted glue, not a parameter bump.
2. **No unrolling → unrolling support.** Mini_Dice has no unroll path. Full DICE needs
   **2-way / 4-way unrolling** in dispatch, RF read/write, and lane handling (already
   tracked as P1 RF items). The lifted glue assumes 1-way; unrolling must be re-added.
3. **Register file: FF-based → SRAM-bank-based.** Mini_Dice's RF is small and **fully
   flip-flop based**. Full DICE has a **larger, SRAM-banked** RF (`dice_register_file` /
   `dice_rf_ctrl`, 32 banks, `dice_ram_1w1r`). The RF *wrapper/handshake* glue inside
   `dice_cgra_rf` is reusable, but the **RF microarchitecture itself is a different
   design** (banking, addressing, read-org, write buffering, SRAM timing).
4. **Predicate register microarchitecture is completely different.** The full-DICE
   predicate RF must be redesigned from scratch — do not port Mini_Dice's predicate
   handling as-is.
5. **Retirement needs cross-backend in-flight visibility (key lesson).** A core finding
   from building Mini_Dice: to retire e-blocks correctly you must **track everything
   in-flight across the whole backend** — pending reads/stores, CGRA pipeline occupancy,
   outstanding memory responses, exec completion. This is exactly what `dice_brt` +
   `dice_backend`'s pipeline counters + scoreboard-release timing implement. **This
   tracking glue is the single most valuable thing to lift**, and it must be re-derived
   for multi-CTA + unrolling (the counts are per-CTA and scale with unroll factor).

**Two mechanical caveats on top of the above:**

- **Defeatured scale is mostly `#define`s.** Mini_Dice sets
  `DICE_NUM_MAX_THREADS_PER_CORE=16`, `DICE_NUM_MAX_CTA_PER_CORE=1` (vs `dice_new`'s
  512 / 4). Some scaling is just defines, but per #1/#2 above the multi-CTA and unroll
  logic is genuinely absent, not merely parameterized away.
- **The memory edge diverges.** Mini_Dice is a **standalone AXI chip**: fetch + ldst go
  over AXI4 / AXI-Lite (`slv_req_t`/`slv_resp_t`) into its own `axi_crossbar` and
  off-chip IO. `dice_new` targets **Vortex's `VX_mem_bus_if`** + a `temporal_coalescing_unit`.
  So the *internal backend glue* ports; the *memory-facing edge* must be re-bridged.

### 🟢 Lift the glue — the missing assembly (closes P0/P1 gaps)

These are valuable for their **wiring / control / in-flight tracking**. Where a row
contains a datapath that diverges (RF, predicate), lift the *structure and handshakes*
and re-implement the internals per the "what differs" list above.

| Mini_Dice file | What it gives `dice_new` | Gap closed | Internals caveat |
|---|---|---|---|
| `BE/dice_backend.sv` | **Keystone.** Wires CGRA-RF wrapper + dispatcher write-back loop + BRT + LDST FIFO + dispatch credit flow + CGRA pipeline-count/empty tracking. | P0 #1,#2,#3,#5 | Counters/tracking must be re-derived **per-CTA** and **per-unroll-factor** |
| `BE/misc/dice_cgra_rf.sv` | RF + CGRA wrapper: `v_o`/ready handshake, latency shift-reg, ldst writeback, CGRA-tid/eblock plumbing. | P0 "CGRA not instantiated" + RF `v_o` | **RF + predicate RF internals differ drastically** (FF → SRAM-bank; predicate uarch redesigned). Keep the wrapper, swap the datapath. |
| `BE/misc/dice_cgra_subs.sv` | CGRA wrapper = `cgra_bitstream_buf_serial` + DORA `dice_top`. | Fabric / config-model question | DORA `dice_top` is regenerated for full-DICE dimensions |
| `BE/misc/cgra_bitstream_buf_serial.sv` | Double-buffered **serial scanchain** bitstream loader for the DORA fabric. | Fabric config model | Largely reusable; size params change |
| `BE/commit_stage/dice_brt.sv` | Block-retire table: insert (pending reads/stores) + retire (load/store/exec) + commit out. **This is the in-flight-tracking glue (lesson #5).** | P0 "commit table commented out" | Must become **per-CTA**; pending counts scale with unroll |
| `BE/regfile/dice_shift_reg.sv` | Tiny parameterized ring-buffer latency shift reg. | `dice_core.sv:155` TODO | **drop-in** (genuinely generic) |
| `BE/misc/dice_ready_to_credit_flow_converter.sv` | Generic BSG ready→credit converter for mem-port backpressure. | dispatch credit flow | **drop-in** (needs BaseJump STL) |
| `FE/dice_frontend.sv` + wired `cgra_core/dice_core.sv` | Structural template for FE/BE wiring + commit feedback to scheduler. | Reference wiring | CTA-id plumbing is missing (single-CTA design) |

### 🟡 Port the logic, re-bridge the edge

| Mini_Dice file | Reusable part | Needs adaptation |
|---|---|---|
| `FE/fetch_stage/branch_handler.sv` (363 lines) | The **real** branch handler (divergence / prefetch / flush) — replaces the `no_branches` stub. | Reconcile interface; multi-CTA stack id |
| `BE/ldst_unit/mem_req_fifo.sv` / `mem_req_fifo_4port.sv` | Enqueue/credit-return/response-routing + scoreboard-release timing. | AXI-Lite master side → swap for `dice_new`'s `VX_mem_bus_if` + `temporal_coalescing_unit` (Mini_Dice has no coalescer) |

### 🔴 Not for Vortex integration (standalone-chip scaffolding)

`rtl/axi_crossbar/*` (PULP axi + common_cells), `rtl/IO/*` (bsg_link, axi_link rx/tx,
flit bridges), `rtl/cgra_core/internal_memory/*` (AXI-lite CSR/mem wraps),
`rtl/chip_top.sv`, `rtl/mini_dice_top/mini_dice_top.sv`. These exist because Mini_Dice
is a standalone SoC. _Exception:_ the `common_cells` (`fifo_v3`, `rr_arb_tree`,
`spill_register`, `lzc`, `addr_decode`) are generic utility cells worth cherry-picking.

### Recommended strategy

Treat Mini_Dice as the **integration blueprint**, not a parts bin:

1. **Lift the glue topology** of `dice_backend` — the module-to-module wiring, the
   write-back loop, and the BRT/pipeline **in-flight tracking** (lesson #5). This is the
   proven part and the biggest time saver.
2. **Keep `dice_new`'s own datapath internals** where they diverge: the SRAM-banked RF
   (`dice_rf_ctrl`/`dice_register_file`), the predicate RF (redesign), and the
   `temporal_coalescing_unit` + `VX_mem_bus_if` memory edge. Drop these into Mini_Dice's
   wrapper shells (`dice_cgra_rf`, `mem_req_fifo` shim) rather than porting Mini_Dice's
   FF-based / AXI versions.
3. **Add the two things Mini_Dice never had:** per-CTA `CTA_ID` tracking threaded through
   the backend, and 2/4-way unrolling. The lifted tracking counters must be re-derived
   per-CTA and scaled by unroll factor.
4. **Drop-in the genuinely generic helpers:** `dice_shift_reg`,
   `dice_ready_to_credit_flow_converter`, `cgra_bitstream_buf_serial` (size params aside).

This converts P0 from "design the integration from scratch" to "port a proven
integration topology, re-implement the diverging internals, and add multi-CTA + unroll."

> Dead file note: `rtl/cgra_core/FE/dice_frontend_top.sv` is empty (0 lines) — the live
> frontend wrapper is `dice_frontend.sv`.

---

## Integration pass 1 — flattened backend

First flattening pass: pulled Mini_Dice's backend glue into `dice_new` and rewrote
`dice_core.sv` to instantiate the backend datapath **directly** (no
`dice_frontend`/`dice_backend`/`dice_cgra_rf`/`dice_cgra_subs` wrappers). Per the
directive, anything that doesn't line up port-wise is left **unconnected with a TODO**
rather than forced. This compiles toward a structure, not a clean elaboration yet.

### Files added / changed

| File | Change |
|---|---|
| `rtl/cgra_core/dice_core.sv` | **Rewritten** — flattened backend (FE kept as-is; CGRA datapath, scanchain loader, shift-reg, BRT, credit converters, TMCU instantiated directly + `dice_backend` glue inlined). |
| `rtl/dice_pkg.sv` | Added `DICE_MEM_DATA_WIDTH` (= metadata width; TODO confirm vs bitstream-cache line). |
| `rtl/cgra_core/cgra_subsystem/regfile/DE_pkg.sv` | Added `NUM_MEM_PORTS`, `DICE_NUM_CONST`, `DICE_NUM_PRED`, `DICE_TOTAL_REGS`, `NUM_CREDITS`, `PENDING_MEM_COUNT_WIDTH`, `MEM_REQ_BUNDLE_FIFO_DEPTH`, and helper functions `gen_mem_port_valid` / `gen_mem_port_op` / `gen_num_loads` (ported from Mini_Dice; additive only). |
| `rtl/cgra_core/commit_stage/dice_brt.sv` | Copied from Mini_Dice. |
| `rtl/cgra_core/cgra_subsystem/regfile/dice_shift_reg.sv` | Copied (module `shift_reg`). |
| `rtl/cgra_core/dispatcher/dice_ready_to_credit_flow_converter.sv` | Copied (needs BaseJump STL). |
| `rtl/cgra_core/cgra_subsystem/cgra_bitstream_buf_serial.sv` | Copied (serial scanchain loader; needs BaseJump STL). |
| `tb/cgra_core/dice_core/filelist.f` | Added `-y` for the built DORA fabric (`dora/.../dice/build/rtl` + `cvfpu`) and BaseJump STL (`bsg_misc`); listed the new backend/commit/ldst modules; dropped `dummy_cgra`. |

> Memory edge: Mini_Dice's `mem_req_fifo` was **deliberately not used** — the memory
> path goes through `dice_new`'s `temporal_coalescing_unit` (TMCU) → Vortex cache.
>
> CGRA fabric: now the **built 32-bit DORA fabric** `dice_top` from
> `dora/examples/devices/dice-isca/dice/build/rtl/` (24 data lanes, 8 pred, 8 mem taps;
> no dedicated special-input ports) — instantiated directly in `dice_core.sv`.

### Wired up

- FE unchanged: `cta_schedule_stage`, `fdr_top` (cm0_if/cm1_if), `dispatcher`,
  `dice_rf_ctrl` (SRAM). The backend now **drives the previously-undriven**
  `cgra_v_lo / cgra_data_lo / cgra_tid_lo` wires.
- `dice_backend` glue inlined: FDR-accept handshake + `fdr_ready` backpressure, latched
  in-flight e-block (`fdr_active_q`), CGRA pipeline-occupancy counter, programming
  pending/handshake state, scoreboard write-back vector from the memory response,
  per-eblock pending read/store counts, exec-retire.
- Dispatcher `wb_valid` / `wb_tid_bitmap` now fed from the memory response (loop closed
  in structure).
- Flattened launch path: RF read → `rf_launch_data_q` → (fabric) → writeback; latency
  via `shift_reg`.
- `cgra_bitstream_buf_serial`, `dice_brt`, and the per-port
  `dice_ready_to_credit_flow_converter` instantiated directly.
- Block-retire commit (`bct_pop_*`) wired back into the scheduler's `eblock_commit_*`.

### Left UNCONNECTED + TODO (the work-list this pass exposes)

1. **CGRA fabric `dice_top` — DONE (wired to the built 32-bit DORA fabric).**
   `dice_core` now instantiates the real `dice_top` from
   `dora/examples/devices/dice-isca/dice/build/rtl/` (added to the dice_core filelist
   via `-y`). It has **24 data-in / 24 data-out lanes, 8 predicate, 8 `ext_mem_o` taps,
   and no dedicated special-input ports** (special-reg values map into the data lanes).
   Remaining fabric-wiring TODOs: (a) **RF-bank → fabric-lane map** (which of the 24
   lanes are GPR vs const vs special); (b) **`ext_mem_o` addr/data pairing** — now
   `port p → {addr=[2p], data=[2p+1]}` per the DORA arch; (c) **predicate launch** —
   wired to `dice_pred_rf`.
2. **TMCU port arbitration** — CGRA emits up to `NUM_MEM_PORTS` ops/cycle; the TMCU
   takes one `incmd`/cycle. Only port 0 is wired; need a 4-port→TMCU arbiter (or one
   TMCU per port).
3. **TMCU → Vortex cache response path** — `outcmd_*` must bridge to a data-cache
   `VX_mem_bus_if` master (cf. `VX_cache_with_temporal.sv`), and responses decoded into
   `mem_rsp_*` (currently all tied 0, so the writeback/scoreboard/store-retire loop is
   structurally present but inert).
4. **Config-memory delivery mismatch** — `dice_new` FDR emits config over `cgra_cm_if`
   (`cm0_if`/`cm1_if`); the scanchain loader wants a flat `cm_wr_{buffer,addr,data,valid}`
   stream. Adapter TODO (inputs tied 0 now).
5. **RF interface gaps** — `dice_new`'s SRAM `dice_rf_ctrl` has no `e_block_id`
   passthrough, no `pred_all_o`, and no per-bank `ldst_pop` retire outputs that
   Mini_Dice's RF exposed; `ldst_wr_i` packing differs. So `dice_brt`'s load-retire
   inputs are tied 0, and special-reg/CTA-id ports are unconnected.
6. **Dispatcher interface gaps** — `dice_new` dispatcher lacks `wb_regs_bitmap` and
   `clear_scoreboard` (per-register release + CTA-clear) that Mini_Dice's had.
7. **`block_commit_table` reconciliation** — `dice_brt` instantiates a `block_commit_table`
   with a different port list than `dice_new`'s existing one; reconcile before elaboration.
8. **Multi-CTA + unrolling** — all the in-flight counters and launch path assume
   single-CTA, 1-way unroll; `CTA_ID` tracking and 2/4-way unroll are not threaded yet.
9. **BaseJump STL dependency** — the copied glue (`cgra_bitstream_buf_serial`,
   `dice_ready_to_credit_flow_converter`) uses `bsg_defines` / BSG cells; ensure the STL
   is on the dice_new compile path.

---

## Integration pass 2 — backend datapath closed (multi-agent build)

Pass 1 left the backend datapath as TODO tie-offs. Pass 2 closed it via a per-module
agent fan-out (one builder agent per module, to fixed port contracts) + a single
integrator pass on `dice_core.sv`, then an adversarial review. **No SV elaborator is
available in this environment, so everything is verified by inspection, not simulation.**

### Decisions taken (you ratified)
- **Lane map:** fixed `GPR0–15` on `ext_data_i_0..15`, `Const0–7` on `ext_data_i_16..23`
  (the 24 lanes feed the fabric's reconfigurable input crossbar).
- **Predicate RF:** new SRAM-banked `dice_pred_rf` (8×1-bit×512), CTA-id via TID bits.
- **CTA aggregate:** N distinct co-scheduled CTAs → per-slice blockIdx table in
  `dice_special_reg`, indexed by `TID[8:7]`.
- **Cache:** data cache instantiated **inside** `dice_core`; mem-side exported as a
  new `VX_mem_bus_if.master dcache_mem_if` port.
- **TMCU arbitration (revised):** **4 TMCUs (one per CGRA mem port)** sharing one L1
  cache — `VX_cache_top`'s `NUM_REQS=4` request crossbar arbitrates the 4 coalesced
  streams before the bank; responses merged round-robin. (Supersedes the earlier
  4→1-serializer-before-one-TMCU design.)
- **Concurrency:** single-e-block-in-flight for this pass.

### New / changed RTL
| File | Change |
|---|---|
| `cgra_subsystem/regfile/dice_pred_rf_ctrl_new.sv` | NEW `dice_pred_rf` (SRAM-banked predicate RF). |
| `ldst_unit/VX_cache_4temporal.sv` | NEW: 4× `temporal_coalescing_unit` → `VX_cache_top` (`NUM_REQS=4` request crossbar) → round-robin response merge. Replaces the serializer + single-TMCU wrapper. |
| `cgra_subsystem/regfile/DE_pkg.sv` | `gen_wb_tid_bitmap()` — one-cycle coalesced-line → returning-thread bitmap (replaces the serial response expander). |
| `ldst_unit/VX_cache_with_temporal.sv` | single-TMCU wrapper (kept for its own TB; `incmd_ready` exported). No longer used by `dice_core`. |
| `cgra_subsystem/regfile/dice_rf_ctrl.sv` | +`tid_o`, `e_block_id_i/o`, `ld_dest_regs_i/o`, `num_stores_i/o`, `rd_const_data_o`, `ldst_pop_o[*]`, `ldst_special_*`; per-slice `dice_special_reg` instantiation. |
| `cgra_subsystem/regfile/dice_wr_ctrl_bank.sv` | per-bank `ldst_pop_o`/`ldst_pop_e_block_id_o`. |
| `cgra_subsystem/regfile/dice_special_reg.sv` | per-slice blockIdx table (params `MAX_CTA_PER_CORE`/`HW_CTA_ID_WIDTH`; `rd_tid_i`, `slice_wr_en_i`, `slice_wr_idx_i`). |
| `cgra_subsystem/regfile/DE_pkg.sv` | `cache_wr_cmd`/`ldst_wr_cmd`/`reg_wr_cmd` += `e_block_id`; `EBLOCK_ID_W`. |
| `dispatcher/.../dispatcher_refactored.sv` + `scoreboard_refactor.sv` | +`wb_regs_bitmap` (per-reg release), +`clear_scoreboard` (CTA clear). |
| `commit_stage/block_commit_table.sv` + `dice_brt.sv` | unified rewrite: multi-bank read-reduce retire **and** per-hw-cta pending **vector**; +`insert_hw_cta_id_i`. |
| `rtl/dice_pkg.sv` | `DICE_MEM_DATA_WIDTH = VX_gpu_pkg::VX_MEM_DATA_WIDTH` (config-mem direct-wire). |
| `rtl/cgra_core/dice_core.sv` | full backend wiring; the `gen_*` `ld_dest_regs` reshape bug fixed. |

### Now wired (was TODO in pass 1)
- Predicate launch/writeback loop (fabric `ext_pred_i/o` ↔ `dice_pred_rf`).
- Lane map with real constants on lanes 16–23 (registered `rd_const_data_o`).
- Memory edge: CGRA 4 ports → **4× `temporal_coalescing_unit`** → `VX_cache_4temporal`
  (`VX_cache_top` `NUM_REQS=4` crossbar arbitrates before the L1; responses merged
  round-robin) → the coalesced line is written to the RF (`assemble_ldst_wr`) and its
  returning threads released to the scoreboard (`gen_wb_tid_bitmap`) **in one cycle**
  (no serial expander) + BRT retire via the RF per-bank `ldst_pop`. Per-port
  `incmd_ready` backpressure; cache `core_rsp_ready` = RF `ldst_ready`; mem-side on
  `dcache_mem_if`.
- Block-retire/commit fully wired (RF `ldst_pop` retire, exec retire, per-hw-cta vector
  into `cta_status_table` via `block_retire_status_t`).
- Dispatcher per-register scoreboard release + CTA-clear.
- Config-mem direct-wire `cm0_if/cm1_if` → scanchain loader.

### Remaining TODOs (carried forward)
1. **`dcache_mem_if` is a NEW port** — `tb_dice_core.sv` must instantiate the interface
   with `DATA_SIZE=DICE_CACHE_LINE_SIZE(32)` + `TAG_WIDTH=DCACHE_MEM_TAG_WIDTH` and a
   backing memory model, else the dice_core TB won't elaborate. The Vortex cache dir
   (`hw/rtl/cache`) must be on the filelist for `VX_cache_top`.
2. **Store-retire tied 0** — `dice_brt.store_retire_valid_i` needs `mem_req` accept +
   block-id from `mem_req_tag` (VX_cache_top tag packing unknown). exec/load retire exact.
3. **Special registers (threadIdx / blockIdx / blockDim / gridDim)** — the regenerated
   fabric (`dice_top`) now has **13 dedicated 32-bit special-reg inputs** (`const_data`,
   `tid_*`, `ntid_*`, `ctaid_*`, `nctaid_*`). These are driven by a **registered
   special-reg block** in `dice_core` (the "Special registers" section): the values are
   latched on the launch (`rf_rd_valid`) so they align 1-for-1 with the registered
   operand data `rf_launch_data_q` presented to the fabric the same cycle — **not** a
   combinational wire from metadata. Sources: blockDim←`schedule_cta_size`,
   blockIdx←`schedule_cta_id`, gridDim←`schedule_grid_size`, **threadIdx**←backend
   decomposition of the **registered launch TID** `rf_tid_lo` (`local %/÷ blockDim`,
   combinational divide then registered — replace with a pipelined divider before timing
   closure). `const_data`←0 (deferred). **`dice_special_reg` was removed** from the
   flattened RF: only its *select mux + per-slice blockIdx table* were redundant — the
   *holding registers* were restored in `dice_core`. `const_reg_i` is kept for the const
   lanes. Remaining gaps: (a) `const_data` source; (b) **per-slice blockIdx** — an
   aggregate e-block (`hw_cta_size>1` = N CTAs) needs N blockIdx, but `fdr_t` carries one
   `schedule_cta_id` and the fabric input is scalar → only the base CTA's blockIdx is
   presented; (c) the RF unit TB (`tb/cgra_core/dispatcher/regfile/dice_rf_ctrl_tb.sv`)
   still drives the removed special-reg ports and needs updating.
4. **2/4-way unrolling** — RF read/write launch is single-TID (lane 0); multi-TID launch
   + `dice_read_org` unroll cases remain.
5. **Lane-map de-swizzle assumption** — assumes RF `rd_data_o` banks 0..15 are
   register-ordered GPR0..15; verify the read de-swizzle vs `shift_bitmap`.
6. **Writeback/release timing** — the coalesced line writes to the RF and releases the
   scoreboard on the same cycle the RF accepts (`core_rsp_valid & ldst_ready`). The RF
   buffers the bank writes (depth-8 `reg_wr_buffer`), so a dependent read very soon after
   release relies on the RF's internal forwarding; verify no RAW window once forwarding is
   confirmed (the BRT load-retire still fires off the actual per-bank `ldst_pop`).
7. **No local SV elaborator** — inspection-verified only; run verilator/slang/xrun against
   `tb/cgra_core/dice_core/filelist.f` to shake out residual width warnings.
