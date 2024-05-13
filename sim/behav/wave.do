onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_MEMs_microphone_driver/clk
add wave -noupdate /tb_MEMs_microphone_driver/rst_n
add wave -noupdate -max 63.0 -radix unsigned -radixshowbase 0 /tb_MEMs_microphone_driver/u_MEMs_microphone_driver/bit_cnt
add wave -noupdate -expand -group 激励信号 /tb_MEMs_microphone_driver/mic_sck
add wave -noupdate -expand -group 激励信号 /tb_MEMs_microphone_driver/ws_edge
add wave -noupdate -expand -group 激励信号 /tb_MEMs_microphone_driver/mic_ws
add wave -noupdate -expand -group 激励信号 /tb_MEMs_microphone_driver/mic_ch0_sdin
add wave -noupdate -expand -group 激励信号 /tb_MEMs_microphone_driver/mic_ch1_sdin
add wave -noupdate /tb_MEMs_microphone_driver/mic_ch2_sdin
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic_data_vld_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic0_data_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic1_data_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic2_data_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic3_data_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic4_data_o
add wave -noupdate -expand -group 模块输出 /tb_MEMs_microphone_driver/mic5_data_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4728466 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ms
update
WaveRestoreZoom {2734127 ps} {9862981 ps}
