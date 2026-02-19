#!/usr/bin/env python3
"""
gen_memfile.py — Convert JSON test vectors to $readmemh-compatible .mem files.

Packs pgraph_meta_t and dice_cta_desc_t structs into hex memory files
matching SystemVerilog packed struct bit layout (MSB-first).

Usage:
    python3 gen_memfile.py kernel_simple.json [--mem-data-width 2048] [--output-dir .]
"""

import argparse
import json
import sys
from pathlib import Path


# =====================================================================
# Bit-width constants (from dice_config.vh)
# =====================================================================
DICE_ADDR_WIDTH      = 32
DICE_KERNEL_ID_WIDTH = 16   # clog2(65536)
DICE_CTA_ID_WIDTH    = 16   # clog2(65536)
DICE_TID_WIDTH       = 9    # clog2(512)
DICE_SMEM_SIZE_WIDTH = 14   # clog2(16384)
PR_INDEX_WIDTH       = 3    # clog2(8)
PGRAPH_OFFSET_WIDTH  = 8    # clog2(256)
BITSTREAM_LENGTH_WIDTH = 8
REG_NUM              = 32   # 16+8+8
REG_INDEX_WIDTH      = 5    # clog2(32)
LD_DEST_COUNT        = 3    # clog2(CGRA_MEM_PORTS-1)+1 = clog2(3)+1 = 3
NUM_STORES_WIDTH     = 3    # clog2(CGRA_MEM_PORTS-1)+1


def parse_int(val):
    """Parse a value that may be int, bool, or hex string."""
    if isinstance(val, bool):
        return int(val)
    if isinstance(val, int):
        return val
    if isinstance(val, str):
        return int(val, 0)
    raise ValueError(f"Cannot parse {val!r} as int")


class BitPacker:
    """Packs fields MSB-first into a big integer, matching SV packed struct order."""

    def __init__(self):
        self.value = 0
        self.total_bits = 0

    def push(self, val, width):
        """Append `width` bits of `val` (MSB-first, i.e., first field goes to MSB)."""
        mask = (1 << width) - 1
        val = val & mask
        self.value = (self.value << width) | val
        self.total_bits += width

    def to_hex(self, pad_width=None):
        """Return hex string, zero-padded to pad_width bits."""
        width = pad_width or self.total_bits
        # Shift left to pad to the full word width (MSB-aligned)
        if width > self.total_bits:
            padded = self.value << (width - self.total_bits)
        else:
            padded = self.value
        hex_chars = (width + 3) // 4
        return format(padded, f'0{hex_chars}x')


# =====================================================================
# Struct packers — field order matches SV packed struct (MSB first)
# =====================================================================

def pack_branch_meta(bm):
    """Pack branch_meta_t (23 bits)."""
    p = BitPacker()
    p.push(parse_int(bm["branch_ena"]),              1)
    p.push(parse_int(bm["branch_uni"]),              1)
    p.push(parse_int(bm["branch_pred_reg"]),         PR_INDEX_WIDTH)
    p.push(parse_int(bm["branch_neg_pred"]),         1)
    p.push(parse_int(bm["is_return"]),               1)
    p.push(parse_int(bm["branch_jump_target_offset"]), PGRAPH_OFFSET_WIDTH)
    p.push(parse_int(bm["branch_reconv_offset"]),    PGRAPH_OFFSET_WIDTH)
    return p


def pack_pgraph_meta(meta):
    """Pack pgraph_meta_t (157 bits)."""
    p = BitPacker()
    p.push(parse_int(meta["bitstream_addr"]),    DICE_ADDR_WIDTH)
    p.push(parse_int(meta["bitstream_length"]),  BITSTREAM_LENGTH_WIDTH)
    p.push(parse_int(meta["unrolling_factor"]),  2)
    p.push(parse_int(meta["lat"]),               8)
    p.push(parse_int(meta["in_regs_bitmap"]),    REG_NUM)
    p.push(parse_int(meta["out_regs_bitmap"]),   REG_NUM)

    # ld_dest_regs: packed [2:0][4:0] = 3 entries of 5 bits each
    ld_regs = meta["ld_dest_regs"]
    for i in range(LD_DEST_COUNT):
        val = parse_int(ld_regs[i]) if i < len(ld_regs) else 0
        p.push(val, REG_INDEX_WIDTH)

    p.push(parse_int(meta["num_stores"]),        NUM_STORES_WIDTH)

    # branch_meta sub-struct
    bm = pack_branch_meta(meta["branch_meta"])
    p.push(bm.value, bm.total_bits)

    p.push(parse_int(meta["barrier"]),           1)
    p.push(parse_int(meta["parameter_load"]),    1)

    return p


def pack_grid_size(gs):
    """Pack dice_grid_size_t: 3 × (CTA_ID_WIDTH+1) = 51 bits."""
    p = BitPacker()
    p.push(parse_int(gs["x"]), DICE_CTA_ID_WIDTH + 1)
    p.push(parse_int(gs["y"]), DICE_CTA_ID_WIDTH + 1)
    p.push(parse_int(gs["z"]), DICE_CTA_ID_WIDTH + 1)
    return p


def pack_cta_size(cs):
    """Pack dice_cta_size_t: 3 × (TID_WIDTH+1) = 30 bits."""
    p = BitPacker()
    p.push(parse_int(cs["x"]), DICE_TID_WIDTH + 1)
    p.push(parse_int(cs["y"]), DICE_TID_WIDTH + 1)
    p.push(parse_int(cs["z"]), DICE_TID_WIDTH + 1)
    return p


def pack_cta_id(cid):
    """Pack dice_cta_id_t: 3 × CTA_ID_WIDTH = 48 bits."""
    p = BitPacker()
    p.push(parse_int(cid["x"]), DICE_CTA_ID_WIDTH)
    p.push(parse_int(cid["y"]), DICE_CTA_ID_WIDTH)
    p.push(parse_int(cid["z"]), DICE_CTA_ID_WIDTH)
    return p


def pack_kernel_desc(kd):
    """Pack dice_kernel_desc_t (175 bits)."""
    p = BitPacker()
    p.push(parse_int(kd["kernel_id"]), DICE_KERNEL_ID_WIDTH)

    gs = pack_grid_size(kd["grid_size"])
    p.push(gs.value, gs.total_bits)

    cs = pack_cta_size(kd["cta_size"])
    p.push(cs.value, cs.total_bits)

    p.push(parse_int(kd["smem_per_cta"]), DICE_SMEM_SIZE_WIDTH)
    p.push(parse_int(kd["start_pc"]),     DICE_ADDR_WIDTH)
    p.push(parse_int(kd["arg_ptr"]),      DICE_ADDR_WIDTH)
    return p


def pack_cta_desc(desc):
    """Pack dice_cta_desc_t (223 bits)."""
    p = BitPacker()

    kd = pack_kernel_desc(desc["kernel_desc"])
    p.push(kd.value, kd.total_bits)

    cid = pack_cta_id(desc["cta_id"])
    p.push(cid.value, cid.total_bits)

    return p


# =====================================================================
# Memory file generation
# =====================================================================

def compute_mem_addr(pc, mem_data_width):
    """Compute the memory word address from a byte PC.

    meta_fetch.sv does: addr = pc >> $clog2(VX_MEM_DATA_WIDTH / 8)
    where VX_MEM_DATA_WIDTH is in bits and the shift converts byte-address
    to word-address.
    """
    word_bytes = mem_data_width // 8
    return pc // word_bytes


def generate_meta_mem(pgraph_list, mem_data_width, output_path):
    """Generate meta.mem file with @ADDR lines."""
    with open(output_path, 'w') as f:
        f.write(f"// Auto-generated metadata memory file\n")
        f.write(f"// Memory data width: {mem_data_width} bits\n")
        f.write(f"// pgraph_meta_t packed width: 157 bits\n\n")

        for entry in pgraph_list:
            pc = parse_int(entry["pc"])
            addr = compute_mem_addr(pc, mem_data_width)
            packed = pack_pgraph_meta(entry["meta"])
            hex_data = packed.to_hex(pad_width=mem_data_width)
            f.write(f"@{addr:08x} {hex_data}\n")

    print(f"  Wrote {output_path} ({len(pgraph_list)} entries)")


def generate_cta_desc_mem(cta_desc, output_path):
    """Generate cta_desc.mem file (single entry at address 0)."""
    packed = pack_cta_desc(cta_desc)
    with open(output_path, 'w') as f:
        f.write(f"// Auto-generated CTA descriptor\n")
        f.write(f"// dice_cta_desc_t packed width: {packed.total_bits} bits\n\n")
        hex_data = packed.to_hex()
        f.write(f"// Packed hex ({packed.total_bits} bits): {hex_data}\n")
        # Also write individual field values for easy SV copy-paste
        kd = cta_desc["kernel_desc"]
        cid = cta_desc["cta_id"]
        f.write(f"// kernel_id={kd['kernel_id']}, "
                f"grid_size=({kd['grid_size']['x']},{kd['grid_size']['y']},{kd['grid_size']['z']}), "
                f"cta_size=({kd['cta_size']['x']},{kd['cta_size']['y']},{kd['cta_size']['z']})\n")
        f.write(f"// smem_per_cta={kd['smem_per_cta']}, "
                f"start_pc={kd['start_pc']}, arg_ptr={kd['arg_ptr']}\n")
        f.write(f"// cta_id=({cid['x']},{cid['y']},{cid['z']})\n")

    print(f"  Wrote {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Convert JSON test vectors to $readmemh .mem files")
    parser.add_argument("json_file", help="Input JSON test vector file")
    parser.add_argument("--mem-data-width", type=int, default=2048,
                        help="Memory data width in bits (default: 2048)")
    parser.add_argument("--output-dir", type=str, default=None,
                        help="Output directory (default: same as JSON file)")
    args = parser.parse_args()

    json_path = Path(args.json_file)
    if not json_path.exists():
        print(f"Error: {json_path} not found", file=sys.stderr)
        sys.exit(1)

    output_dir = Path(args.output_dir) if args.output_dir else json_path.parent
    output_dir.mkdir(parents=True, exist_ok=True)

    with open(json_path) as f:
        data = json.load(f)

    stem = json_path.stem  # e.g., "kernel_simple"
    print(f"Processing {json_path.name} (mem_data_width={args.mem_data_width} bits)")

    # Generate metadata memory file
    if "pgraph_metadata" in data:
        meta_path = output_dir / f"{stem}_meta.mem"
        generate_meta_mem(data["pgraph_metadata"], args.mem_data_width, meta_path)

    # Generate CTA descriptor reference file
    if "dice_cta_desc" in data:
        cta_path = output_dir / f"{stem}_cta_desc.mem"
        generate_cta_desc_mem(data["dice_cta_desc"], cta_path)

    print("Done.")


if __name__ == "__main__":
    main()
