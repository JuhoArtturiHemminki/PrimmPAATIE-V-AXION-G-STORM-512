module tr512_core #(
    parameter [63:0] PHI_CONSTANT = 64'h9E37_79B9_7F4A_7C15
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic [8:0]   delta_n,
    output logic [63:0]  e_drift,
    output logic         proactive_alert
);

    logic [8:0]  delta_prev;
    logic [63:0] e_drift_reg;
    logic [63:0] delta_diff;

    always_comb begin
        if (delta_n >= delta_prev) begin
            delta_diff = {55'h0, (delta_n - delta_prev)};
        } else begin
            delta_diff = {55'h0, (delta_prev - delta_n)};
        }
    end

    logic [63:0] current_drift_weight;
    assign current_drift_weight = delta_diff * PHI_CONSTANT;
    assign proactive_alert = (current_drift_weight > 64'h00FF_FFFF_FFFF_FFFF);
    assign e_drift = e_drift_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            delta_prev  <= 9'h000;
            e_drift_reg <= 64'h0000_0000_0000_0000;
        } else begin
            delta_prev  <= delta_n;
            e_drift_reg <= e_drift_reg + current_drift_weight;
        }
    end

endmodule
