===== HOLD (MIN) CHECKS =====

Startpoint: b[0] (input port clocked by clk)
Endpoint: _835_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: min

   Delay     Time   Description
-----------------------------------------------------------
   0.000    0.000   clock clk (rise edge)
   0.000    0.000   clock network delay (ideal)
   2.000    2.000 ^ input external delay
   0.038    2.038 ^ b[0] (in)
   0.068    2.106 v _804_/Y (sky130_fd_sc_hd__o22ai_1)
   0.098    2.204 ^ _806_/Y (sky130_fd_sc_hd__a21oi_1)
   0.000    2.204 ^ _835_/D (sky130_fd_sc_hd__dfxtp_1)
            2.204   data arrival time

   0.000    0.000   clock clk (rise edge)
   0.000    0.000   clock network delay (ideal)
   0.400    0.400   clock uncertainty
   0.000    0.400   clock reconvergence pessimism
            0.400 ^ _835_/CLK (sky130_fd_sc_hd__dfxtp_1)
  -0.042    0.358   library hold time
            0.358   data required time
-----------------------------------------------------------
            0.358   data required time
           -2.204   data arrival time
-----------------------------------------------------------
            1.846   slack (MET)