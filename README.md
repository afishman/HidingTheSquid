-----------------------
Overview
-----------------------

Welcome to the squid simulator. The code here can be used to generate the simulations from the paper: http://rsif.royalsocietypublishing.org/content/12/108/20150281

Basically cephalopods are awesome, especially the way their skin rapidly changes colour. https://www.youtube.com/watch?v=PmDTtkZlMwM

The magic is in their chromatophores cells - https://www.youtube.com/watch?v=1pJPnZFSy5o - these little ones expand and contract to change the host's perceived skin colour. It would be really cool if one day we could mimic their chromomorphic wizardry into something we could wear.

Anyways, one way we could do that is to get a sheet of Dielectric Elastomer and coat it with a bunch of coloured electrodes as cells. Three independantly controlled chromatophores have already been fabricated: https://www.youtube.com/watch?v=W2CgtJU3ckY

Then, by coordinating the cells atuation in a cellular-automata like fashion, we can impose simple rules that yield complex patterns that propagate over the surface of the skin. Proof of principle can be seen: 

Videos generated with this simulator can be seen:
Type II Behaviour - https://www.youtube.com/watch?v=H5wG2jPh2cE
Type III Behaviour - https://www.youtube.com/watch?v=nWg-Lu5Xzm8

------------
Output format:
------------
The `SimulateThread.m` class performs simulations. Output data is stored in the /Sims/ folder with two files:
<name>.csv - Stores time, local state and global state data
<name>.mat - Stores the instance of the SimulateThread object

There are scripts in the /Sims/ folder that generate the simulations in the paper.

------------
Viewing the Output:
------------
Use the SimViewer class for this. If too much data is being loaded during class construction, include the resolution argument

This contains many functions to view output. Your best buddies here are:
- PlotMaterial
- PlotGlobal

TODO: talk about report generation

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

In general, use the static Thread.ConstructThreadWithSpacedElectrodes to construct your thread (the actual Thread constructor provides a more flexible way, but will require more work to make it sim ready). This makes a thread with equally spaced, locally controlled electrodes, with the first electrode externally controlled

WARNING: This tries to figure out the coarsest possible element length, so keep an ```I''' on it. If it messes up you might get one that is stupidly coarse 
(though works as it should for the provided sims)

Prior to constructing the thread you'll need to construct the following:
- LocalSwitchingModel (for the self-sensing cells, look in the SwitchingModelsLocal folder)
- ExternalSwitchingModel (look in the SwitchingModelsExternal folder, includes cyclic/step) *** now includes insightful static Demo methods ***
- ... as well as arguments for the number of cells, prestretch, their dimensions and spacing

------------
Adjusting Other model parameters:
------------
I use defaults for the rest of the parameters. If you want to view/adjust these look in:
- Element subclasses
- MaterialParameters (adjust the static Default method, which was a silly thing to implement)
