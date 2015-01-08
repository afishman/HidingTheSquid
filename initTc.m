clear all
clc

load oneNeighLong.mat

TC = obj.R* obj.eRel * obj.L^2 * obj.T^-1 * obj.preStretch^4
