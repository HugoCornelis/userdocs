Creating GENESIS 3 Simulations with Python
==========================================

**Related Documentation:**

`Index of GENESIS 3 User Tutorials <../tutorial-genesis/tutorial-genesis.html>`_

Introduction
------------

This is an introduction to creating G-3 simulation scripts in Python,
using the SSPy component of G-3.  It also provides information on the
differences and similarities with `SSP (Simple Scheduler in Perl)
<../ssp/ssp.html>`_ in the current G-3 Developers Release.

`SSPy (Simple Scheduler in Python) <../sspy/sspy.html>`_ serves as a Python
version of SSP in that it encapsulates the operations for loading and
running a complete simulation.  It also provides a shell similar to the
`G-shell <../gshell/gshell.html>`_.  Most importantly, it provides an
Applications Programming Interface (API) for interfacing with scripts
written in Python.  This means that a Python script that loads and runs a
G-3 simulation, can also make use of the many GUI toolkits (e.g. wxPython),
analysis and visualization tools (e.g. Matplotlib, which provides Python
objects to replicate much of the functionality of Matlab), and Python
modules for scientific computing such as scipy and numpy.

The SSPy documentation gives an overview of the use of the shell and of
basic use of the API.  This tutorial extends this documentation with an
example based on the GENESIS 'simplecell' model that was used in Tutorial 3
`Convert a GENESIS 2 Simulation to GENESIS 3
<../tutorial3/tutorial3.html>`_.  In this tutorial, a GENESIS 2 script for
the Script Language Interpreter (SLI) was converted to a NDF model format
file for G-3 and tested by running a current clamp simulation in the
G-shell.  The cell model used was 'simplecell', a simple two-compartment
neuron, that has been used in many GENESIS tutorials.  The soma compartment
'/cell/soma' contains Hodgkin-Huxley type voltage-activated sodium and
potassium channels (implemented as tabchannels), and the single dendrite
compartment '/cell/dend' contains excitatory and inhibitory synaptically
activated channels (implemented as synchans).

When collected together, the G-shell commands illustrated in Tutorial 3 would
be::

   ndf_load simplecell-nolib.ndf
   runtime_parameter_add /cell/soma INJECT 0.5e-9
   output_add /cell/soma Vm  
   output_filename simplecell-test_Vm.out
   heccer_set_timestep 20.0e-6
   run /cell 0.5
   quit

To run this as an executable command line script, save it in a file, and
add the line at the top::

    #!/usr/local/bin/genesis-g3

The following tutorial illustrates how to run this model or similar ones
with SSPy.

Using SSPy as a replacement for G-shell
---------------------------------------

The `SSPy documentation  <../sspy/sspy.html>` describes how
to invoke the interactive shell with the ''--shell'' option to sspy,
and how to use the 'help' command within the shell.

With the present Developers Release, the command ''sspy --shell'' must
be given witin the '~/neurospaces_project/sspy/source/snapshots/0'
directory.  To use it for models located in an arbitrary directory of
your own, give the full path::

  $ ~/neurospaces_project/sspy/source/snapshots/0/sspy --shell

Once you have done this, use the 'help' command to explore the commands
available within the shell.  Although the commands listed by this command
are very similar to the G-shell 'list commands' result, there are a few
differences to be aware of.

**NOTE:** These are true for the July 2011 G-3 Developers Release, and
the syntax of commands used in the G-shell and SSPy will likely converge
in later releases.  They are offered for this preliminary documentation.

1. The G-shell has both a 'runtime_parameter_add' and a
   'model_parameter_add' command.  At present, the distinction
   between a parameter that is intrinsic to the model ("model parameter")
   and one that is set at runtime ("runtime_parameter") is somewhat fuzzy.
   They SSPy shell has a single 'model_parameter_add' that is used to
   set model or runtime parameters.  Thus the injection should be set
   with::

       model_parameter_add /cell/soma INJECT 0.5e-9

2. The G-shell 'run' command takes only a time argument value in seconds.
   With the SSPy implementation (as seen with 'help run'), the value is
   interpreted as time in seconds if it is a floating point value, and a
   number of steps, if it is an integer.  With the default 20.0e-6 sec
   simulation timestep, the following command would also run the simulation
   for 0.5 second::

       run /cell 25000

3. Both shells have a 'output_resolution <integer-factor>' command
   that allows the time between output steps to be an integer multiple
   of the simulation time step.  However, they each have limitations
   in present implementation.  

   The G-shell command is only valid if the output_mode is set to "steps"
   instead of the default empty string.  Thus, the commands needed to
   increase the output interval would be::

       output_mode steps
       output_resolution 5

   The output mode determines whether the first column of the output
   is the number of steps or the simulation time for the remaining
   data on the line.
   
   The SSPy shell does not have an 'output_mode' command, and the
   default output_mode is the simulation time. However, the
   'output_resolution' command requires that the 'run' command
   specifies the time, not the number of steps.  (i.e., the situation
   is the reverse of that with G-shell.

4. You will notice that some commands produce slightly different
   output.  Under the G-shell 'list_elements' gives only the top
   level elements, e.g. '/cell' for the loaded NDF file.  To
   see the subelements of the dendrite excitatory channel, one would
   use the full path 'list_elements /cell/dend/Ex_channel'.  The SSPy
   shell 'list_elements' command gives the entire recursive list, by
   default.

With these commands, you should be able to reproduce the results produced
in the G-shell.

Scripting with Python
---------------------

The script `simplecell-test.py <figures/simplecell-test-py.txt>`_
reproduces the result above, but allows the inclusion of any available
Python modules and the use of any valid Python commands.

It begins with a standard header that will be used for any script that
you will write::

    #! /usr/bin/env python
    import pdb
    import os
    import sys

At this point, you may import any other Python modules that you need
for use in your scripts, such as 'matplotlib' for graphics.

The following command is needed in order to provide a path to the libraries
needed by SSPy.  It will likely not be required in later releases::

    sys.path.append( os.path.join(os.environ['HOME'],
        'neurospaces_project/sspy/source/snapshots/0/tests/python'))

Next, the location of the NDF model files to be loaded must be specified.
Cell models are continually being added to the model library located in::

  /usr/local/neurospaces/models/library/cells/

Some recent additions, including the 'simplecell-nolib.ndf' file used
here, are described in the document `Some NDF files of converted GENESIS 2
models <../models-library-additions/models-library-additions.html>`_.
If there is a model there that you wish to run, you can specify the
path with::

  os.environ['NEUROSPACES_NMC_MODELS']='/usr/local/neurospaces/models/library/cells'

In this tutorial, the model to be used will be one of ours in the current
directory, so the line will read::

  os.environ['NEUROSPACES_NMC_MODELS']= '.'

A G-3 simulation involves the cooperation of various
`Components <../genesis-components/genesis-components.html>`_.  The basic
ones needed to run a cell model are the Scheduler (SSP or SSPy), The
Neurospaces Model Container (NMC), and the solver (generally heccer).

These lines set up SSPy as the scheduler component::

  from test_library import add_sspy_path
  add_sspy_path()
  from sspy import SSPy 
  scheduler = SSPy(verbose=True)

To avoid the output of messages to the console window, set
``verbose=False``.

The next set of lines create a model container that will hold the cell
model::

  my_model_container = scheduler.CreateService(name="My Model Container",
      type="model_container", verbose=True)

To reduce the amount of debugging output, set 'verbose=False' in this
and following statements.  Next, the model can be loaded into
'my_model_container', using the 'simplecell-nolib.ndf' model or
one of your choice::

  my_model_container.Load('simplecell-nolib.ndf')

At this point, you can set model parameters, such as the injection::

  my_model_container.SetParameter('/cell/soma', 'INJECT', 0.3e-09)

Once the model has been set up, a solver, heccer, has to be provided and
linked to the model, and a time step set::

  my_heccer = scheduler.CreateSolver('My solver', 'heccer', verbose=True)
  my_heccer.SetModelName('/cell')
  my_heccer.SetTimeStep(20e-06)

Then some form of output has to be provided::

  my_output = scheduler.CreateOutput('My output object', 'double_2_ascii')
  my_output.SetFilename('simplecell_soma_Vm.out')
  my_output.AddOutput('/cell/soma', 'Vm')

In the first line above, an output object is created and scheduled for
simulation.  The first argument is a name, and the second is one of the
output types listed with the SSPy shell 'list_output_plugins' command:
'double_2_ascii', 'line', and 'live_output'.  'double_2_ascii' is the
default type for the G-shell and SSPy shell create_output command.  The
second line is analogous to 'output_filename', and the third to
'add_output'.

Optionally, the output resolution can be changed with::

  my_output.SetResolution(5)

Finally, the scheduler is given the command to run the simulation for 0.5
seconds::

  scheduler.Run(time=0.5)

or alternatively for an equivalent number of steps::

  scheduler.Run(steps=25000)

Some variations
---------------

The 'SetParameter' command for the model container can set other
simulation parameters that affect the simulation.  Instead of setting
the soma injection current, the 'FREQUENCY' field of the synaptically
activated excitatory channel in the dendrite compartment can be set
with::

  my_model_container.SetParameter('/cell/dend/Ex_channel', 'FREQUENCY', 200.0)

in order to produce Poisson-distributes random activation with an avergage
frequency of 200 Hz.

Comments in  `simplecell-test.py <figures/simplecell-test-py.txt>`_
illustrate some variations on providing output::

  # an alternate way is to add output to the top level SPPy object
  # This is useful when interfacing with a GUI
  # scheduler.AddOutput('/cell/soma', 'Vm')

  # to apply this to a particular output object 'output1', one would use
  # scheduler.AddOutput('/cell/soma', 'Vm', 'output1')

[In next revision, add more on the last example.]

By setting the output object type to 'line', the output will be sent
to stdout, line by line as it would to an output file.  This is useful
when piping the output to another program or Python object for
analysis or plotting.  When the output object type is 'live_output',
the data is output to a list of lists such as::

 [
   [value1, value2, value3] # value for all outputs at step 0
   [value1, value2, value3] # value for all outputs at step 1
   ...
   [value1, value2, value3] #value for all outputs at step 2501
 ]

The list of all values at step 0 is given by::

  output_data[0]

and all values at step 100 is::

  output_data[100]

A typical usage in a script would be::

  my_output = scheduler.CreateOutput('My output object', 'live_output')
  my_output.AddOutput('/cell/soma', 'Vm')
  my_output.AddOutput('/cell/dend', 'Vm')

  scheduler.Run(steps=2500)
  output_data = my_output.GetData()

  print "Data at step 100, time '%f' is %s" % (output_data[100][0],
      ','.join(map(str, output_data[100][1])))

In a GUI, if you wanted to run the simulation in a thread you can pass
the output to the data portion of the GUI and refresh it while it is
running. 

Adding graphical output within a script
---------------------------------------

The  'live_output' output object type can be used to make simulation
output easily accessible for plotting within the Python simulation
script.  The script shown above can be modified to end with the
statements::

  my_output = scheduler.CreateOutput('My output object', 'live_output')
  my_output.AddOutput('/cell/soma', 'Vm')
  scheduler.Run(steps=25000)

  data = my_output.GetData()

  import matplotlib.pyplot as plt

  x = []; y = []

  for line in data:
      x_value = line[0]
      y_value = line[1][0]
      x.append(x_value)
      y.append(y_value)

  plt.plot(x, y)
  plt.title('Membrane Potential')
  plt.xlabel('seconds')
  plt.ylabel('Volts')
  plt.show()

This produces a plot similar to that produced by the G-3 standalone
application *plotVm.py*, included with the current G-3 distribution.

Interfacing models with other Python objects and functions
----------------------------------------------------------

To be continued ....

