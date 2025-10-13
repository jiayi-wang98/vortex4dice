// simple_ram.sv
module simple_ram #(
  parameter WIDTH = 32,
  parameter DEPTH = 512,
  parameter ADDR_WIDTH = $clog2(DEPTH)
)(
  input  logic              clk,
  // Write
  input  logic              wr_en,
  input  logic [ADDR_WIDTH-1:0] wr_addr,
  input  logic [WIDTH-1:0]  wr_data,
  // Read
  input  logic              rd_en,
  input  logic [ADDR_WIDTH-1:0] rd_addr,
  output logic [WIDTH-1:0]  rd_data
);

  logic [WIDTH-1:0] mem [0:DEPTH-1];

  always_ff @(posedge clk) begin
    if (wr_en)
      mem[wr_addr] <= wr_data;
  end

  always @(posedge clk) begin
    if (rd_en)
      rd_data = mem[rd_addr];
  end

  //load memory from file for simulation
  task load_memory_from_file(input string filename);
    int fd;
    int status;
    string line;
    fd = $fopen(filename, "r");
    if (!fd) begin
      $fatal("Cannot open memory initialization file: %s", filename);
    end
    int addr = 0;
    while (!$feof(fd) && addr < DEPTH) begin
      status = $fgets(line, fd);
      line = line.trim();
      if (line.len() < WIDTH) continue; //skip invalid lines
      for (int b = 0; b < WIDTH; b++)
        mem[addr][WIDTH-1 - b] = (line[b] == "1");
      addr++;
    end
    $fclose(fd);
    $display("[%0t] Loaded %0d words into RAM from %s", $time, addr, filename);
  endtask

  task save_memory_to_file(input string filename);
    int fd;
    fd = $fopen(filename, "w");
    if (!fd) begin
      $fatal("Cannot open memory output file: %s", filename);
    end
    for (int addr = 0; addr < DEPTH; addr++) begin
      string line = "";
      for (int b = 0; b < WIDTH; b++) begin
        line = {line, mem[addr][WIDTH-1 - b] ? "1" : "0"};
      end
      $fwrite(fd, "%s\n", line);
    end
    $fclose(fd);
    $display("[%0t] Saved %0d words from RAM to %s", $time, DEPTH, filename);
  endtask
endmodule
