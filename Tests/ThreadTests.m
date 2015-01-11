classdef ThreadTests < matlab.unittest.TestCase
    
    properties (TestParameter)
        %For the should not add electrode test
        StartPoints = {[0,0], [0,1], [0,1], [0,1], -1};
        Lengths =     {[1,1], [4,1], [2,2], [2,1], 1 };
    end
    
    methods (Test)
        %Tests that two electrodes right next to each other should add
        function ShouldAddElectrode(this)
            import matlab.unittest.constraints.HasLength;
            
            thread = ThreadTests.AddManyElectrodes([0,1], [1,1]);
            
            this.verifyThat(@()thread.Electrodes, HasLength(1));
        end
        
    end
    
    methods (Test, ParameterCombination='sequential')
        %overlapping electrodes / ones outside of thread fail
        function ShouldNotAddElectrodeTest(this, StartPoints, Lengths)
            import matlab.unittest.constraints.Throws;
            
            this.verifyThat(@()ThreadTests.AddManyElectrodes(StartPoints, Lengths), ...
                Throws(?MException));
        end
    end
    
    methods (Static)
        %Easier way to run a test class
        function Run
            suite = matlab.unittest.TestSuite.fromFile([mfilename, '.m']);
            suite.run
        end
        
        %Constructs a new thread and adds a set of electrodes
        function thread = AddManyElectrodes(startPoints, lengths)
            thread = ThreadTests.TestThread;
            
            for i = 1:length(startPoints)
                thread.AddElectrode(startPoints(i),lengths(i), ElectrodeTypeEnum.Undefined);
            end
        end
        
        %Default thread for testing
        function thread = TestThread
            stretchedLength = 4;
            resolution = 1;
            preStretch = 2;
            rcCircuit = RCCircuit.Default;
            
            thread = Thread(stretchedLength, resolution, preStretch, rcCircuit);
        end
    end
end
