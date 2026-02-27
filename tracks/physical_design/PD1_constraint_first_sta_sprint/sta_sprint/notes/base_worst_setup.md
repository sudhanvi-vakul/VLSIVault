===== SETUP (MAX) CHECKS =====

Startpoint: a[1] (input port clocked by clk)
Endpoint: _850_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max

   Delay     Time   Description
-----------------------------------------------------------
   0.000    0.000   clock clk (rise edge)
   0.000    0.000   clock network delay (ideal)
   2.000    2.000 v input external delay
   0.000    2.000 v a[1] (in)
   0.195    2.195 ^ _600_/X (sky130_fd_sc_hd__xor2_1)
   0.092    2.286 v _613_/Y (sky130_fd_sc_hd__a21oi_1)
   0.178    2.464 ^ _615_/Y (sky130_fd_sc_hd__o22ai_1)
   0.126    2.590 v _616_/Y (sky130_fd_sc_hd__a21oi_1)
   0.193    2.783 v _617_/X (sky130_fd_sc_hd__o21a_1)
   0.221    3.004 ^ _638_/Y (sky130_fd_sc_hd__o21ai_0)
   0.161    3.166 v _653_/Y (sky130_fd_sc_hd__a21boi_0)
   0.258    3.424 ^ _665_/Y (sky130_fd_sc_hd__o21ai_0)
   0.135    3.559 v _684_/Y (sky130_fd_sc_hd__a21oi_1)
   0.259    3.818 ^ _700_/Y (sky130_fd_sc_hd__o21ai_0)
   0.135    3.953 v _717_/Y (sky130_fd_sc_hd__a21oi_1)
   0.221    4.174 v _732_/X (sky130_fd_sc_hd__o21a_1)
   0.200    4.374 v _748_/X (sky130_fd_sc_hd__o21a_1)
   0.195    4.568 v _762_/X (sky130_fd_sc_hd__o21a_1)
   0.246    4.815 ^ _781_/Y (sky130_fd_sc_hd__o21ai_0)
   0.170    4.985 ^ _793_/X (sky130_fd_sc_hd__a31o_1)
   0.060    5.045 v _800_/Y (sky130_fd_sc_hd__o21ai_0)
   0.166    5.211 v _801_/X (sky130_fd_sc_hd__o21a_1)
   0.000    5.211 v _850_/D (sky130_fd_sc_hd__dfxtp_1)
            5.211   data arrival time

  10.000   10.000   clock clk (rise edge)
   0.000   10.000   clock network delay (ideal)
  -0.200    9.800   clock uncertainty
   0.000    9.800   clock reconvergence pessimism
            9.800 ^ _850_/CLK (sky130_fd_sc_hd__dfxtp_1)
  -0.115    9.685   library setup time
            9.685   data required time
-----------------------------------------------------------
            9.685   data required time
           -5.211   data arrival time
-----------------------------------------------------------
            4.474   slack (MET)


The launch point of this setup path is the input port a[1], which is treated as being clocked by clk and includes an input external delay of 2.0 ns. This means the data is launched from logic outside the design and enters the chip through this input. 

The capture point is the flip-flop 850, which captures the data on the rising edge of the same clock. This is an input-to-register timing path analyzed under the clk path group. 

The data path delay is dominated by a long chain of combinational logic between the input and the capture flip-flop, consisting mainly of complex AOI/OAI logic cells such as o21a, o21ai, and a21oi, each contributing incremental delay. 

The accumulated combinational delay, rather than clock network delay (which is ideal in this report), is the primary contributor to the overall arrival time. Despite the long logic depth, the path meets setup timing with a positive slack of 4.474 ns.