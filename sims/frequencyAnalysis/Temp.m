clear all

viewer = SimViewer('TypeIBehaviour');
close all
[freqs, amp] = viewer.FFTOfFirstVertex;
plot(freqs, amp);