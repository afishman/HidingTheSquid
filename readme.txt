Hi all!

Welcome to the squid simulator, I do hope you enjoy using it =]

-----------------------
Overview
-----------------------

NOTE: ALL classes are reference types.

------------
Output format:
------------
The `SimulateThread.m` class performs simulations. Output data is stored in the /Sims/ folder with two files:
<name>.csv - Stores time, local state and global state data
<name>.mat - Stores the instance of the SimulateThread object

There are scripts in the /Sims/ folder that generate the simulations in the paper. I didn't include the data here because it was rather large,... and to let you have a good ol' laugh simulating yourself :)

------------
Viewing the Output:
------------
Use the SimViewer class for this. If too much data is being loaded during class construction, include the resolution argument

This contains many functions view output. Your best buddies here are:
- PlotMaterial
- PlotGlobal


-----------------------
More Info
-----------------------

------------
Performing simulations:
------------
Look at the examples in the /Sims/ folder, they will give you much direction.

Basic flow is:
1. Construct a Thread object
2. Construct a SimulateThread object using that thread
3. On the SimulateThread object use `RunSim` to run a simulation from the start (which will OVERWRITE any previous data of the same name)


Since large threads take rather long to simulate you can crtl+c out of them. They can be continued with the static SimulateThread.ContinueSim(name, tMax) method. This can help if you want to view the output as you go along.

------------
Constructing Threads:
------------
When you construct your thread, view it with Thread.Plot

In general, use the static Thread.ConstructThreadWithSpacedElectrodes to construct your thread (the actual Thread constructor provides a more flexible way, but will require more work to make it sim ready). This makes a thread with equally spaced - locally controlled electrodes. (I tend to then set the Thread.StartElectrode.Type to an external type)

WARNING: This tries to figure out the coarsest possible element length, so keep an ```I''' on it. If it messes up you might get one that is stupidly coarse 
(though works as it should for the provided sims)

Prior to constructing the thread you'll need to construct the following:
- RCCircuit (just holds the source voltage and resistance params)
- LocalSwitchingModel (for the self-sensing cells, look in the SwitchingModelsLocal folder)
- ExternalSwitchingModel (look in the SwitchingModelsExternal folder, includes cyclic/step) *** now includes insightful static Demo methods ***
- ... as well as arguments for the number of cells, prestretch, their dimensions and spacing

------------
Adjusting Other model parameters:
------------
I use defaults for the rest of the parameters. If you want to view/adjust these look in:
- Gent_Model
- Material_Parameters (adjust the static Default method, which was a silly thing to implement)

-----------------------
Extending the model
-----------------------
You should make a class that inherits from Element and edit the ElementConstructor property in Thread.

I have tried to anticipate what will need to be changed for the new model in the the Abstract methods of Element:
-Capacitance
-CapacitanceDot (rate of capacirance)
-Width
-NaturalWidth

should think should work for at least the fiber constrained model.

Feel free to abstract more away as necessary. There is also a git repo here, if that's your thing - go ahead and commit forth!
