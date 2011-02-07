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


from g3.nmc import ModelContainer

def run_simulation(simulation_time):

    my_dt = 1e-5


    #---------------------------------------------------------------------------
    # 
    # Create a model container and some compartments
    #---------------------------------------------------------------------------

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
        "INJECT": 1e-9
        }
        )

    # Second Example: use a wildcard to activate edogenous synapses

    my_nmc.Query("setparameterconcept spine::/Purk_spine/head/par 25")
    my_nmc.Query("setparameterconcept thickd::gaba::/Purk_GABA 1")


    #---------------------------------------------------------------------------
    # Create a Heccer solver for processing the model.
    #
    # We should able able to add all of the relevant data to the object
    # on initialization via the constructor.
    #---------------------------------------------------------------------------

    from g3.heccer import Heccer
    
    my_heccer = Heccer(name="/cell")

    my_heccer.SetModel(my_nmc)

    my_heccer.CompileAll()


    #---------------------------------------------------------------------------
    # Create an output generator for Heccer.
    #
    # This involves creating an output generator, retrieving the address
    # of the variable you wish to obtain output for, and adding it to
    # the generator.
    #---------------------------------------------------------------------------
    from g3.experiment.output import Output

    my_output_gen = Output("/tmp/output")
  
    address = my_heccer.GetAddress("/cell/soma", "Vm")
  
    my_output_gen.AddOutput("output", address)


    #---------------------------------------------------------------------------
    # Create an array of objects to be scheduled.
    #---------------------------------------------------------------------------

    schedulees = []


    # schedule heccer
    schedulees.append(my_heccer)
    schedulees.append(my_output_gen)

    current_time = 0.0

    while current_time < simulation_time:

        for sched in schedulees:

            current_time += my_dt
          
            sched.Step(current_time)


    
    my_heccer.Finish()
    my_output_gen.Finish()
  
    print "Done!"


#------------------------------------------------------------------------------
# Main program, executes a simulation with
# with 0.5 seconds.
#------------------------------------------------------------------------------
if __name__ == '__main__':
    run_simulation(0.5)
