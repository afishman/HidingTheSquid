clc
 
figures = JournalFigureStub.empty;
figures = [figures, CrossectionFigures, TypeIFigures, TypeIIFigures];

for figure = figures
    figure.WriteToFile;
end