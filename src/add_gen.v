`timescale 1ns/1ps
`ifndef ADDR_GEN_V
`define ADDR_GEN_V

module add_gen (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire       enable,
    input  wire       dir,
    output reg  [5:0] addr,
    output reg        addr_valid,
    output reg        done
);

    localparam IDLE = 2'd0,
               RUN  = 2'd1;

    reg [1:0] state;
    wire at_end;
    wire [5:0] addr_next;

    assign at_end    = (dir == 1'b0) ? (addr == 6'd63) : (addr == 6'd0);
    assign addr_next = (dir == 1'b0) ? (addr + 6'd1)  : (addr - 6'd1);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            addr       <= 6'd0;
            addr_valid <= 1'b0;
            done       <= 1'b0;
        end else begin
            // done is cleared only on start
            if (start) begin
                done <= 1'b0;
            end

            case (state)
                IDLE: begin
                    if (start) begin
                        state      <= RUN;
                        addr       <= (dir == 1'b0) ? 6'd0 : 6'd63;
                        addr_valid <= 1'b1;
                    end
                end

                RUN: begin
                    addr_valid <= 1'b1;
                    if (enable) begin
                        if (at_end) begin
                            done       <= 1'b1;
                            addr_valid <= 1'b0;
                        end else begin
                            addr <= addr_next;
                        end
                    end
                end

                // ---- FIX: default branch for safety ----
                default: begin
                    state      <= IDLE;
                    addr       <= 6'd0;
                    addr_valid <= 1'b0;
                    done       <= 1'b0;
                end
            endcase

            // Restart mid‑run
            if (start && (state == RUN)) begin
                state      <= RUN;
                addr       <= (dir == 1'b0) ? 6'd0 : 6'd63;
                addr_valid <= 1'b1;
                // done is already cleared by the earlier start condition
            end
        end
    end

endmodule
`endif
