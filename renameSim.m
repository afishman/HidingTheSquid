% function renameSim(oldName, newName)
oldName = 'oneNeighLong';
newName ='oneNeighLongBin';

%%%Routine
%Delete anything there
delete([newName, '.mat'])
delete([newName, '.txt'])

%Copy over the text file
copyfile([oldName, '.txt'],[newName, '.txt']);

%Load the Object adn rename it
load(oldName)
obj.name = newName;

%Save the object
save(newName, 'obj');

%Delete old
delete([oldName, '.mat'])
delete([oldName, '.txt'])