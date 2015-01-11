clear all
close all

loadedData = CSV_IO('sawOsc');

for state = loadedData.States
    state.SetState;
    clf
    state.Thread.Plot
    title(sprintf('%.2f(s)', state.Time));
    pause(0.3);
end
