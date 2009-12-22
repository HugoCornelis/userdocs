#!/usr/bin/python
# load the SingleCellContainer library
import sys
sys.path.append('/usr/local/glue/swig/python')
import Neurospaces.SingleCellContainer

#
# Function runs a simulation with the set parameters.
# Takes the simulation time as an argument.
#
def run_simulation(simulationtime):
   
    # create a cell for simulation
    c = Neurospaces.SingleCellContainer.Cell("/cell");

    # create a cylindrical segment inside the cell, and set its properties
    s = Neurospaces.SingleCellContainer.Segment("/cell/soma");

    s.parameter("Vm_init", -0.0680)
    s.parameter("RM", 1.000)
    s.parameter("RA", 2.50)
    s.parameter("CM", 0.0164)
    s.parameter("ELEAK", -0.0800)

    s.parameter("DIA", 2e-05)
    s.parameter("LENGTH", 4.47e-05)

    # first example: apply current injection to the soma
    s.parameter("INJECT", 1e-9)

    # second example: use a wildcard to activate endogenous synapses
    Neurospaces.SingleCellContainer.query("setparameterconcept spine::/Purk_spine/head/par 25")
    Neurospaces.SingleCellContainer.query("setparameterconcept thickd::gaba::/Purk_GABA 1")
    
    # redirect output to the given file
    Neurospaces.SingleCellContainer.set_output_filename("/tmp/output")
    
    # compile the model
    Neurospaces.SingleCellContainer.compile("/cell")
    
    # define the output variables
    Neurospaces.SingleCellContainer.output("/cell/soma", "Vm")
    
    # run the simulation
    Neurospaces.SingleCellContainer.run(simulationtime)


#
# Main program, executes a simulation with
# with 0.5 seconds.
#
if __name__ == '__main__':
    run_sumulation(0.5)

