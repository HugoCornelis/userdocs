Summary of tests with the testchannels package
==============================================

The 'testchannels' package was developed to test backwards compatibility of
GENESIS 3 (G3) with GENESIS 2 (G2) for scripts that use different GENESIS
commands or options for filling the channel gate tables.  These are
described in the "Units Conversion" documentation.
(http://genesis-sim.org/userdocs/units-conversion/units-conversion.html)
In the process of testing, other backwards compatibility issues were
also discovered.  The results of these tests, carried out in February 2011,
are described in this document.

To simplify the analysis, several of the models use the same
two-compartment 'simplecell' model, with different Na and K channels, or
different GENESIS commands or options for filling the channel tables. 
The 'simplecells/' directory of this package has tests for many of the
problems encountered in testing more complex models.  For example,
the 'simplecell-M' model implements the solution to an exercise in the
GENESIS Modeling Tutorial section "Building a cell the easy way"
(http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/simplecell-tut.html).
This fails to run under GENESIS 3 for reasons that are more fully explored
in the 'simplecells/' tests.

The script 'simplecells/simplecell_spike_pulse.g' was designed to be used
as a very simple script that can be mapped to G3 Python commands as a short
example that does something non-trivial.  The script is less complex than
those in the "input-models" test package, but illustrates the same
challenge of creating an experimental protocol in a script, and then saving
and running it in NDF format.  For simplicity, this version does not have a
graphics option for use with G2.

The script executes three functions::

  make_input - provide pulsed spike trains to /cell/dend/Ex_channel
  make_cell - readcell of the simplecell cell.p file
  make_output - output the Ex_channel current at intervals out_dt < dt

and then executes function 'step_tmax' to run the simulation

Note that this cleanly separates the user workflow steps of (1) Construct
model; (2) Design experiment; (3) Run simulation; (4) Check and analyze
results.  It does (4) in a trivial way, by just outputting the synchan
current, but in principle it could sum synaptic currents over all cells in
a network, and output the sum for Fourier analysis as simulated MEG
signals.  This example should be runnable with either sli_run, or with
ndf_load.  It fails to run with G3 because backwards compatibility has not
yet been implemented for SLI descriptions of experimental or
output/analysis protocols.

The most complex model studied is the 'BDK5cell2' layer 5 cortical
pyramidal cell model with 9 compartments and 9 voltage or calcium activated
channels in the soma.  This is proposed as a initial set of channels for
testing the RTXI dynamic clamp interface.  The original 'BDK5cell' model
cannot be run with G3, but the BDK5cell2 model provides an equivalent
"workaround" that can be saved and run as an NDF model.

These tests revealed the following "bugs" or  unimplemented features that
prevented G2 scripts from running properly under G3, although workarounds
are available for some:

* There does not seem to be a specification of xmin and xmax for
  parameterized gate tables in the NDF files.  Thus the 'range' option
  of setupalpha is ignored with 'ndf_load', although apparantly not for
  'sli_run'.

* ndf_load generates dramatically incorrect results when TABFILL is used to
  expand a gate table having a voltage range (xmin and xmax) other
  than the commonly used -0.1 to 0.05 V.  The scripts run properly with
  sli_run, and the NDF file generated with ndf_save properly sets the
  values of ``HH_TABLE_START`` and ``HH_TABLE_END``.  The table value for a
  given index corresponds to the correct voltage in the specified range, so
  the xmin and xmax were evidently used properly in filling the table with
  ndf_save.  Possibly, ndf_load is ignoring this information.

* When a cell model having gate tables filled with TABFILL is saved with
  'ndf_save', the final point is missing.  For example, if the G2 model has
  ``xdivs = 3000`` (3001 points) the NDF file only has 3000 points, omitting
  'table[3000]'.  This is not of much consequence, as it correctly preserves
  the voltage difference between points.

* Once the compartment injection has been set, sli_run will ignore any
  attempts to change it, defeating attempts to provide a substitute for
  a scriptable pulsegen connection.

* sli_run ignores any attempt to activate a synchan by setting its
  frequency field to a non-zero value.

* It is not possible to replace the unimplemented 'scaletabchan' function
  in sli_run by accessing gate table values with 'getfield' and then
  modifying them.  It seems that all table values in objects that use
  G2 interpol_structs (tables) should  be accessible with 'getfield'
  and 'setfield', but they are not.

* The channel gate fields X_A->sx, X_A->sy, X_A->ox, X_A->oy, and the
  corresponding fields for the B tables can be set in G2 to provide
  a scaling equivalent to 'scaletabchan'.  sli_run ignores the setting
  of these fields, but produces no error messages.  It is not possible
  to use ndf_load, because these fields are not represented in the
  NDF file.

* There is a surprising bug/feature in GENESIS 2 hsolve that prevents
  the use of a different voltage range for one of the channels. This is not
  a G3 issue, but may be related to G3 problems with non-standard xmin and
  xmax of gate tables.

* Both sli_run and ndf_load produce errors if an attempt is made to
  output the conductance (Gk) of a synchan to a file.

* It is not yet possible to create an input model for a cell in G3, using a G2
  SLI script that connects device objects together and delivers them as a
  stimulus to a cell.  This is because there is not yet a translation from
  a SLI message-based description of an experimental protocol to an NDF
  representation.

* It is not possible to set a different output clock when running a loaded
  NDF model in the gshell, and have the time recorded in the output file.
  The 'output-resolution' command allows an output step that is larger by an
  integer factor, but it requires that the step number, rather than the
  simulation time be recorded in the file.  The 'output_mode' should not
  be constained to "steps".

* The commands 'scaletabchan' and 'setuptau' have not been implemented.

* The G3 cell reader cannot deal with branched symcompartment models.  At
  present, this is not a high priority feature to implement, because there
  is a procedure for creating an approximately equivalent model with
  asymmetric compartments. However, it means that most cell models created
  with NEURON will not give exactly reproduceable results under G3.

Notes on gate table scaling and shifting
----------------------------------------

Problems involving the scaling and shifting of tabchannel gate table values
constitute a large category of "bugs" or "ns-sli deficiences" encountered
in these tests.

Many GENESIS 2 channel creation scripts create a tabchannel with A and B
gate tables that contain 3001 points, or 3000 divisions (the 'xdivs'
field).  The usual voltage range (specified by 'xmin' and 'xmax') is from
-0.1 to 0.05 V.  This is the default behavior of the 'setupalpha' function.
This range is appropriate because action potentials can safely assumed to
be within this range.  However, there are many reasons to use a wider
voltage range and to allow scaling and shifting of the gate table values.

When constructing a new cell model by populating a morphology with
channel models taken from various sources, it is usually necessary to
make some changes in the channel activation functions that can be
accomplished by scaling or shifting gate table values.  For example,
"Q10 scaling" or adjustments for temperature differences between
species or experimental conditions depend on scaling of 'tau'.

When using a channel model in a cell with a different resting potential
than the cell for which it was developed, it is common to shift both 'tau'
and the 'minf' functions up or down along the x-axis (voltage) by an amount
depending on the resting potential.  This insures that, when the cell is at
its resting potential, the channel will be in the same state of activation
that it would be in the original cell at rest.

G2 uses a global variable 'EREST_ACT' for shifting of activation and tau
curves along the voltage axis.  Section 1.3.1 "Conversion of Parameterized
Constants to SI Units" of the 'units-conversion' document describes how
EREST_ACT affects the values of the gate 'setupalpha' parameters.  The
activation time constant 'tau' can be scaled without affecting the
activation if the A and B tables are scaled by the same amount.  This may
be seen from "units-conversion" Eqs. (11) and (12).

There is a potential problem when shifting gate tables, however.  Shifting
of tables along the x-axis is accomplished by moving data values up and
down in the tables.  This means that data can spill out of the ends of the
tables and be lost.  This can be prevented by making extra room at the end
of the tables with a wider range of voltages ('xmin' and 'xmax') than would
be strictly required.  Some of the G2 'Neurokits/prototypes' scripts, such
as 'yamadachan.g' use a range of -0.1 to 0.1 V.

In spite of its antiquated XODUS-based GUI, the channel editor of the G2
'Neurokit' application continues to be a powerful and useful tool for
"tuning" a cell model.  It is based upon the G2 methods for scaling and
shifting gate tables.  G3 will at some point need a Python-based channel
editor that gives this capability with a much better GUI.

There are four ways that scaling and shifting may be performed in
GENESIS 2.

1. At the time of creation, by modifying the setpalpha parameters or
   equations used to fill the tables.  The use of the 'EREST_ACT' variable
   described above is a simple way to perform shifts along the voltage
   axis.  However, this does not provide for adjustments when "tuning"
   a channel that has already been created.

2. By use of the sx, sy, ox, oy fields of a tabchannel to perform scaling
   and offset of the A and/or B gate tables.  This is similar to the use of
   'scaletabchan' to perform the operation on alpha, beta, tau, or minf,
   and may often used as a replacement by scaling A and B appropriately.

3. By use of 'scaletabchan' to change the channel gate tables.  The
   values of alpha, beta, tau, or minf may be scaled or offset along
   the x or y axes by specifying a value of sx, sy, ox, or oy.

4. By use of script commands to get table values, modify them, and set them to
   the new value.

At present, only the first of these methods is possible with G3.
