clc
 
figures = JournalFigureStub.empty;
figures = [figures, TypeIFigures, TypeIIFigures];

for figure = figures
    figure.WriteToFile;
end