clc
 clear all
figures = JournalFigureStub.empty;
%figures = [figures, CrossectionFigures, TypeIFigures, TypeIIFigures, TypeIIIFigures];
figures = CrossectionFigures;


for figure = figures
    figure.WriteToFile;
end