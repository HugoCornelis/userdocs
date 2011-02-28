"""
Working scripting example for running a
model with G3 via python. Functionally the same
as the current example, however this shows more
of the operations involved in setting up and running
a complete simulation via python.

Version 1.
"""

__author__ = 'Mando Rodriguez'
__credits__ = []
__license__ = "GPL"
__version__ = "1"
__status__ = "Development"

import os
import pdb
import sys

# This append may go away later. 
sys.path.append("/usr/local/glue/swig/python")

"""
Comment: Python script running a simple model with G-3.
"""
from g3.nmc import ModelContainer

def run_simulation(simulation_time):
    my_dt = 1e-5
    
#------------------------------------------------------------------------------
# Create a model container and some compartments
#------------------------------------------------------------------------------
    my_nmc = ModelContainer()
    my_cell = my_nmc.CreateCell("/cell")
    my_segment = my_nmc.CreateSegment("/cell/soma")

    my_segment.SetParameters(
        {
        "Vm_init": -0.0680,
        "RM": 1.000,
        "RA": 2.50,
        "CM": 0.0164,
        "ELEAK": -0.0800,
        "DIA": 2e-05,
        "LENGTH": 4.47e-05,
        }
        )

# Apply current injection to the soma
    my_segment.SetParameter("INJECT", 1e-9)

#----------------------------------------------------------------------------- 
# Create a Heccer for processing the model stored by the model container.
#------------------------------------------------------------------------------
    from g3.heccer import Heccer
    my_heccer = Heccer(name="/cell", model=my_nmc)
    my_heccer.CompileAll()

#----------------------------------------------------------------------------- 
# Create an output generator and link it to the variable of interest.
#------------------------------------------------------------------------------
    from g3.experiment.output import Output
    my_output = Output("/tmp/output")
    my_output.AddOutput("output", my_heccer.GetAddress("/cell/soma", "Vm"))

#----------------------------------------------------------------------------- 
# Create an array of objects to be scheduled.
#------------------------------------------------------------------------------
    schedulees = []

    # schedule heccer
    schedulees.append(my_heccer)
    schedulees.append(my_output)

    current_time = 0.0
    while current_time < simulation_time:
        current_time += my_dt

        for schedulee in schedulees:
            schedulee.Advance(current_time)

    my_heccer.Finish()
    my_output.Finish()
  
#------------------------------------------------------------------------------
# Main program executes a simulation of 0.5 seconds.
# The if statement allows use of this file as an executable or as a library.
#------------------------------------------------------------------------------

if __name__ == '__main__':
    run_simulation(0.5)


