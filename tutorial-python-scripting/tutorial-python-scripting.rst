Creating GENESIS 3 Simulations with Python
==========================================

**Related Documentation:**

.. start: userdocs-tag-replace-items related-tutorial
.. end: userdocs-tag-replace-items related-tutorial

`Index of GENESIS 3 User Tutorials <../tutorial-genesis/tutorial-genesis.html>`_

`Creating a G-3 GUI with Python <../tutorial-python-gui/tutorial-python-gui.html>`_

Introduction
------------

This is an introduction to creating G-3 simulation scripts in Python,
using the SSPy component of G-3.  It also provides information on the
differences and similarities with `SSP (Simple Scheduler in Perl)
<../ssp/ssp.html>`_ in the current G-3 Developers Release.

**Some background for beginners with Python**

The explanations of the example Python scripts in this tutorial assume a
"beginner's" knowledge of Python programming, equivalent to a weekend
spent looking through a book on introductory Python programming and
experimenting with the examples.  There are also many good tutorials
and examples on the web.  With this basic knowledge of Python syntax
and what follows in this tutorial, you should have the information you
need to modify these examples to create your own G-3 simulations
by writing short scripts in Python.  As with the previous GENESIS 2 `Modeling
Tutorials <http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/genprog.html>`_,
the approach taken here is to build up a sequence of model simulations
and explain the simulation scripts in enough detail so that you can use
them as templates to modify for your own simulations.

Here are some useful links for learning how to program in Python:

The `official Python documentation site <http://docs.python.org>`_ has a
well-organized index to the available documentation.  The `Python Tutorial
<http://docs.python.org/tutorial/>`_ is a good staring place.  Be sure to
read the chapter on *Classes*, as these G-3 examples will be based on the
use of the object-oriented features of Python.

A short book on introductory Python programming that doesn't try to give
too much detail would be a good preparation for digging into more detailed
documentation from the web. At some point, you will want to consult the
`Python Language Reference <http://docs.python.org/reference/>`_.  This
will be useful for looking up syntax that you don't understand in an
example.

The Simple Scheduler in Python (SSPy)
-------------------------------------

Before starting in with a Python scripting example, it is useful to know
something about the `SSPy (Simple Scheduler in Python) <../sspy/sspy.html>`_
component of G-3.  SSPy serves as a Python
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

   ndf_load cells/simplecell-nolib.ndf
   runtime_parameter_add /cell/soma INJECT 0.5e-9
   output_add /cell/soma Vm  
   output_filename simplecell-test_Vm.out
   heccer_set_timestep 20.0e-6
   run /cell 0.5
   quit

To run this as an executable command line script, save it in a file, and
add the line at the top::

    #!/usr/local/bin/genesis-g3

The following tutorial example shows how to run this model or similar ones
with SSPy.

Using SSPy as a replacement for G-shell
---------------------------------------

The `SSPy documentation <../sspy/sspy.html>`_ describes how
to invoke the interactive shell with the ``--shell`` option to sspy,
and how to use the 'help' command within the shell.

With the present Developers Release, the command ``sspy --shell`` must
be given witin the '~/neurospaces_project/sspy/source/snapshots/0'
directory.  To use it for models located in an arbitrary directory of
your own, give the full path::

  $ ~/neurospaces_project/sspy/source/snapshots/0/sspy --shell

Once you have done this, use the 'help' command to explore the commands
available within the shell.  Although the commands listed by this command
are very similar to the G-shell 'list commands' result, there are a few
differences to be aware of.

**NOTE:** These are true for the Current G-3 Developers Release, and
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
   in the present implementation.  

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

An interactive shell is very useful for debugging and testing out commands.
Both the G-shell and the newer SPPy shell will continue to be used for
this.  However, you will typically use a text editor to edit executable
scripts written in Python that import the necessary G-3 Python modules.
The script `simplecell-test.py <figures/simplecell-test.txt>`_ reproduces
the result above, but allows the inclusion of any available Python modules
and the use of any valid Python commands.

It begins with a standard header that will be used for any script that
you will write::

    #! /usr/bin/env python
    import pdb   # the Python debugger
    import os
    import sys

The first line indicates that it is to be proecessed by running 'python',
and the next three include standard Python libraries that are used
with SSPy. At this point, you may import any other Python modules that you need
for use in your scripts, such as 'matplotlib' for graphics, or the custom
G-3 graphical widgets used in the next tutorial in this series.

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

or alternatively if it is one of or own in another directory, such as the
current one::

  os.environ['NEUROSPACES_NMC_MODELS']= '.'

In the previous tutorial, we used the gshell to create a NDF format file
for the simplecell model.  Now, the model exists in the library as
'simplecell-nolib.ndf', so we use the first version.

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

  my_model_container.Load('cells/simplecell-nolib.ndf')

At this point, you can set model parameters, such as the injection::

  my_model_container.SetParameter('/cell/soma', 'INJECT', 0.3e-09)

Once the model has been set up, a solver, heccer, has to be provided and
linked to the model, and a time step set::

  my_heccer = scheduler.CreateSolver('My solver', 'heccer', verbose=True)
  my_heccer.SetModelName('/cell')
  my_heccer.SetTimeStep(20e-06)

Then some form of output has to be provided::

  my_output = scheduler.CreateOutput('My output object', 'double_2_ascii')
  my_output.SetFilename('simplecell_soma_Vm.txt')
  my_output.AddOutput('/cell/soma', 'Vm')

In the first line above, an output object is created and scheduled for
simulation.  The first argument is a name, and the second is one of the
output types listed with the SSPy shell 'list_output_plugins' command:
'double_2_ascii', 'line', and 'live_output'.  'double_2_ascii' is the
default type for the G-shell and SSPy shell create_output command.
It is equivalent in most ways to the GENESIS 2 'asc_file' object type.  The
second line is analogous to 'outfile', and the third to
'make_output' in the GENESIS 2 script `simplecell-g3.g
<../tutorial3/figures/simplecell-g3.txt>`_ in the previous tutorial.

Optionally, the output resolution can be changed with::

  my_output.SetResolution(5)

Finally, the scheduler is given the command to run the simulation for 0.5
seconds::

  scheduler.Run(time=0.5)

or alternatively for an equivalent number of steps::

  scheduler.Run(steps=25000)

To run the script, check to be sure that the file permissions are set as
"executable" and simply type 'simplecell-test.py'.  This is made possible
by the first line of the file, which indicates that Python is to be invoked
to run the script.  After running the script, you may view the resulting file
'simplecell_soma_Vm.txt' with the G-3 standalone application *g3plot* which
is installed with the current G-3 distribution::

    $ g3plot simplecell_soma_Vm.txt

Some variations
---------------

The 'SetParameter' command for the model container can set other
simulation parameters that affect the simulation.  Instead of setting
the soma injection current, the 'FREQUENCY' field of the synaptically
activated excitatory channel in the dendrite compartment can be set
with::

  my_model_container.SetParameter('/cell/dend/Ex_channel', 'FREQUENCY', 200.0)

in order to produce Poisson-distributed random activation with an average
frequency of 200 Hz.

Comments in  `simplecell-test.py <figures/simplecell-test.txt>`_
illustrate some variations on providing output::

  # an alternate way is to add output to the top level SPPy object
  # This is can be useful when interfacing with a GUI
  # scheduler.AddOutput('/cell/soma', 'Vm')

  # to apply this to a particular output object 'output1', one would use
  # scheduler.AddOutput('/cell/soma', 'Vm', 'output1')

However, in the current series of tutorial examples, we will continue to
invoke AddOutput() on the output object.

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
running.  (This will be illustrated in a future tutorial.)

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
application *plotVm.py* or *g3plot*, also included with the current G-3 distribution.

Other Models to Try
-------------------

The plots produced by these variations of the simplecell model are all
rather boring.  This is because the basic 'squid-like' channels used in
the soma produce no spike frequency adaptation or interesting firing
patterns.  This is just what is required in a squid axon, but not in
a cortical neuron.  For an interesting exercise, modify these scripts
to to use the `RScell model
<http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/cells/RScell/>`_
from the library 'cells/RScell-nolib2.ndf', or the De Schutter and Bower
1994 Purkinje cell model in 'cells/purkinje/edsjb1994.ndf'.

For other examples of scripting G-3 simulations with Python, see the latest
test scripts by updating your G-3 installation (or just the sspy component) and
looking in::

  ~/neurospaces_project/sspy/source/snapshots/0/tests/python/

Interfacing models with other G-3 objects
-----------------------------------------

The `Experiment component <../experiment/experiment.html>`_ of G-3
contains definitions of a number of object classes that can be interfaced
with a model in order to implement experimental protocols for model
stimulation and recording of results.  The output objects used in the
examples above are among these.  The `Perfect Clamp
<../pclamp.pclamp.html>`_ and PulseGen are others.

The example script `simplecell_pulse.py <figures/simplecell_pulse.txt>`_
extends `simplecell-test.py <figures/simplecell-test.txt>`_ to create a
G-3 'pulsegen' as an Input object and use it for current injection to the
soma.  It also allows a choice of output devices, and specification of
pulse generator parameters.

The script, which is best viewed in another window or tab while reading
these explanations, begins by importing the usual Python modules, and then
defines some default parameters to be used in the simulation::

  # Boolean flags used for simulation output - pick one or both
  file_out = True  # output to file
  live_out = True  # live output to list of lists

  Vm_file = 'simplecell_pulse_Vm.txt'

  tmax = 0.5 # default run time

  # Injection pulse parameters
  # for constant injection, use injwidth = tmax, injdelay = 0

  injcurrent = 0.3e-9 # default injection current
  injdelay = 0.05     # default delay before injection pulse
  injwidth = 0.2     # default width of injection pulse
  injinterval = 0.25 # use a large repetition interval for a single pulse

It then follows with the usual commands that that set up needed paths and
that create a Scheduler, Model Container, and Solver.

After setting up the heccer Solver time step as before, the script continues with::

  # Create a pulsegen object for current injection
  my_pulsegen = scheduler.CreateInput('pulsegen','pulsegen',verbose=True)
  my_pulsegen.AddInput('/cell/soma', 'INJECT')

  my_pulsegen.SetLevel1(injcurrent)
  my_pulsegen.SetDelay1(injdelay)
  my_pulsegen.SetWidth1(injwidth) 
  my_pulsegen.SetLevel2(0.0)
  my_pulsegen.SetWidth2(0.0)
  my_pulsegen.SetDelay2(injinterval - injdelay)

  # alternatively, give it a very long delay to prevent repeating
  # my_pulsegen.SetDelay2(100.0)

  my_pulsegen.SetBaseLevel(0.0)
  my_pulsegen.SetTriggerMode(0) # zero is "free run"

The G-3 implementation of 'pulsegen' follows that of the GENESIS 2 pulsegen
object, with two separate sets of output levels, delays, and pulse widths.
The second set allows for its use in two-step voltage clamp experiments
with a conditioning pulse.  Normally, only Delay1, Level1, and Width1 are
used for a single current injection pulse, and Delay2 can be used to specify
the time before it is repeated.  Documentation for the `GENESIS 2 pulsegen
<http://genesis-sim.org/GENESIS/Hyperdoc/Manual-26.html#ss26.49>`_ gives
further details of the pulsegen parameters.

The code assigns default values to these parameters such that after a delay
of 50 msec, there will be a pulse of height 0.3 nA, lasting for 200 msec,
and then repeated with the same delay.

Note the use of the CreateInput() method of the scheduler to use the
pulsegen for input.  The created 'my_pulsegen' object has methods for
AddInput(destination_segment, segment_parameter) and Set methods for the
pulsegen parameters.   These are invoked as illustrated above.

Then, the example script provides some more flexibility on providing output
by using the conditional statements::

  # Create Outputs
  if file_out:
      Vm_file_out = scheduler.CreateOutput('File Out', 'double_2_ascii')
      Vm_file_out.SetFilename(Vm_file)
      Vm_file_out.AddOutput('/cell/soma', 'Vm')
      # Provide output a multiple of the simulation time step
      Vm_file_out.SetResolution(5)

  # It is also possible to have two separate output objects
  if live_out:
      Vm_live_out = scheduler.CreateOutput('Live Out', 'live_output')
      Vm_live_out.AddOutput('/cell/soma', 'Vm')
      # Provide output a multiple of the simulation time step
      Vm_live_out.SetResolution(5)

As both 'file_out' and 'live_out' were set to 'True' at the beginning of
the script, output of the soma Vm will be directed both to the file
''simplecell_pulse_Vm.txt', and to a data structure (a Python list of
lists) called 'Vm_live_out'.  This example makes no use of the latter.
However, it will be used in the next tutorial in this series.

The other addition made in this script is the definition of two functions
to make use of the script easier::

  def set_inject_pulse(current, delay, width, interval):
        my_pulsegen.SetLevel1(current)
	my_pulsegen.SetDelay1(delay)
	my_pulsegen.SetWidth1(width)
	my_pulsegen.SetDelay2(interval - delay)

  def run_simulation(simulationtime):
          scheduler.Run(time=simulationtime, finish=False)

The first one provides a simple way of changing the injection pulse
parameters, and the second one illustrates a variation of the
``scheduler.Run(time=0.5)`` command used to run the previous example.
The Run method of the scheduler has a 'finish' option with a default
value of 'True'.  This causes the objects that were allocated to be
destroyed at the end of a run.  This may be desirable in some cases
for large models, but in these examples, we would like to be able to
re-run the simulation again with new parameters.

These definitions are used in the last lines of the script::

  # run with default injection

  print 'Started run: system time = ', time.time()
  run_simulation(tmax)
  print 'Completed run: system time = ', time.time()

The statements to print out the system time make use of the imported 'time'
module.  After ``run_simulation(tmax)`` runs the simulation with the
desired options, there is an option to uncomment the last four lines::

  ## uncomment the following lines to change parameters, Reset, and re-Run

  # set_inject_pulse(0.5e-09, 0.05, 0.4, 100.0)
  # Vm_file_out.SetAppend(True)
  # scheduler.Reset()
  # run_simulation(tmax)

The first of these uses the function  set_inject_pulse defined above to
give a new set of injection pulse parameters.  

The second one illustrates the SetAppend() method of the output object.  Here
it is invoked on only the 'File Out' object 'Vm_file_out', with the
assumption that it exists.  The default behavior of the output classes is
with SetAppend(False), insuring that the file is overwritten after a Reset
and a new Run.  Setting it True here is similar to setting the 'append'
flag of the GENESIS 2 'asc_file' object, so that the second run will be
appended to the first, instead of overwriting it.

The Reset method of the SSPy Scheduler sets the simulation time to zero,
and performs the Reset method on other objects that are managed by the
scheduler.  This is necessary to before running the simulation again.

Then, a final 'run_simulation(tmax)' re-runs the simulation for the time
tmax and the script exits after printing a message.

In the next tutorial in this series `Creating a G-3 GUI with Python
<../tutorial-python-gui/tutorial-python-gui.html>`_, we will learn how to
interface this model with a scripted Python graphical environment that has
a Control Panel to set model and simulation parameters and run the
simulation, and that has graphs for plotting results.  However, there is one
more step required before we can use this simulation as a separate module
in such an environment.  That is to make it truly modular and
object-oriented by implementing it as a Python class definition.  Then, it
can be instantiated as an object, e.g. 'mySim' with accessible parameters
and methods.

Creating a G-3 simulation object
--------------------------------

One advantage of implementing a complete simulation (or large part of one)
as a separate object, is that it is easier to run in a separate thread,
either for parallellization, or for independence from the GUI modules.
This would allow, for example, a button on the Control Panel to stop a
running simulation, or for results to be plotted as the simulation runs.

This example will not make use of mult-threading, but will illustrate
the first step in using it as an independent module to be run either as
a stand-alone script, or controlled from a GUI or other Python program.

When the final example script in this tutorial, `simplecell_pulse_sim.py
<figures/simplecell_pulse_sim.txt>`_ is run as a main script, it creates
a G3Sim instance 'mySim', sets injection parameters and outputs, then
runs it for 0.5 seconds, generating the same output in the file
'simplecell_pulse_Vm.txt' as produced by
`simplecell_pulse.py <figures/simplecell_pulse.txt>`_.

It will be useful to look at the listings of these two scripts while reading
the following explanations.

'simplecell_pulse_sim.py' begins with the usual header and import
statements, and then it defines a class::

    class G3Sim():
        def __init__(self):
          ''' "__init__" is invoked whenever an object is created from this class.
            This defines and initializes all the parameters and methods
            (defined functions) of the object.
          '''
          # -------------- default simulation parameters -------------

          # Boolean flags used for simulation output - pick one or both
          self.file_out = True  # output to file
          self.live_out = True  # live output to list of lists

The first definition within the class is its '__init__' method.  As stated
in the comment, the statements within this definition will be executed
automatically when an object of class G3Sim is created.  The method
definition continues with the rest of the statements found in
simplecell_pulse.py, but with with all of the variable and object names
preceded by 'self.'.  There are no other statements other than this
method definition within the class definition.

The purpose of the use of 'self' can be seen in the lines at the end of the script
that follow the G3Sim class definition::

  if __name__ == '__main__':
      mySim = G3Sim()
      # run with default injection parameters
      print 'Started run: system time = ', time.time()
      mySim.run_simulation(mySim.tmax)
      print 'Completed run: system time = ', time.time()

      ## uncomment the following lines to change parameters, Reset, and re-Run
      # mySim.set_inject_pulse(0.5e-09, 0.05, 0.4, 100.0)
      # mySim.Vm_file_out.SetAppend(True)
      # mySim.scheduler.Reset()
      # mySim.run_simulation(mySim.tmax)

The 'if' statement checks to see if the script is being run as a main
stand-alone program, rather than as being imported as a module by another.
In this case, it executes these statements which correspond to the final
statements of 'simplecell_pulse_sim.py'.

When the object 'mySim' is created from the G3Sim class definition, the
initialization code is executed, initializing the variables and creating
the needed objects and method definitions.  In the class definition, 'self' refers to the
G3Sim class object that will be created.  Thus the  command::

      mySim.run_simulation(mySim.tmax)

invokes the run_simulation() method of the simulation object, and uses the
object variable 'tmax'.

Uncommenting the last four lines results in a change of parameters, a
Reset, and a second run with these parameters, adding the results to
the output file, as with the original 'simplecell_pulse.py'.

The other thing to note is the different way that the functions
'set_inject_pulse' and 'run_simulation' are defined in
'simplecell_pulse_sim.py' when they are methods of a class::

    def set_inject_pulse(self, current, delay, width, interval):
        self.my_pulsegen.SetLevel1(current)
        self.my_pulsegen.SetDelay1(delay)
	self.my_pulsegen.SetWidth1(width)
        self.my_pulsegen.SetDelay2(interval - delay)

    def run_simulation(self,simulationtime):
          self.scheduler.Run(time=simulationtime, finish=False)

In these definitions, they have an extra argument 'self', that is not used
when they are invoked.

With this script as a starting point, the G-3 Python scripting tutorials
continue with the next tutorial `Creating a G-3 GUI with Python
<../tutorial-python-gui/tutorial-python-gui.html>`_.  In this tutorial we
will add a Control Panel and a graph, using a set of G-3 Python widgets
that mimic the appearance and functionality of those used in GENESIS 2 with
XODUS.

