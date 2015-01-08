function TC = adjustToTC(obj, t)

initTC = obj.R* obj.eRel * obj.L^2 * obj.T^-1 * obj.preStretch^4;

TC = t./initTC; 
