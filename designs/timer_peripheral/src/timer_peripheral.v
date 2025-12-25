module timer_peripheral (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output reg         irq
);

    reg        timer_en;
    reg [31:0] count_reg;
    reg [31:0] compare_reg;
    reg        irq_status;

    localparam ADDR_CTRL    = 4'h0;
    localparam ADDR_COUNT   = 4'h4;
    localparam ADDR_COMPARE = 4'h8;
    localparam ADDR_STATUS  = 4'hC;

    always @(posedge clk) begin
        if (!reset_n) begin
            timer_en     <= 1'b0;
            count_reg   <= 32'd0;
            compare_reg <= 32'd0;
            irq_status  <= 1'b0;
            irq         <= 1'b0;
        end else begin
            if (wr_en) begin
                case (addr)
                    ADDR_CTRL:    timer_en     <= wdata[0];
                    ADDR_COUNT:   count_reg   <= wdata;
                    ADDR_COMPARE: compare_reg <= wdata;
                    ADDR_STATUS:  irq_status  <= 1'b0;
                    default: ;
                endcase
            end

            if (timer_en) begin
                count_reg <= count_reg + 1'b1;
                if (count_reg == compare_reg)
                    irq_status <= 1'b1;
            end

            irq <= irq_status;
        end
    end

    always @(*) begin
        if (rd_en) begin
            case (addr)
                ADDR_CTRL:    rdata = {31'd0, timer_en};
                ADDR_COUNT:   rdata = count_reg;
                ADDR_COMPARE: rdata = compare_reg;
                ADDR_STATUS:  rdata = {31'd0, irq_status};
                default:      rdata = 32'd0;
            endcase
        end else begin
            rdata = 32'd0;
        end
    end

endmodule
