Some NDF files of converted GENESIS 2 models
============================================

This describes some GENESIS 2 single cell and channel models that have been
converted to G-3 NDF format for inclusion in the
'/usr/local/neurospaces/models/library' directory.  The list of model
categories may be seen with the g-shell command 'library_show'.  The cells
and channels are listed with the commands 'library_show ndf cells' and
'library_show ndf channels'.

The NDF format files in the cells/ directory were produced with the gshell
'sli_load" and 'ndf_save' commands from GENESIS 2 SLI scripts that create
a cell '/cell' from prototpe compartments in '/library'. A typical set of
commands to generate the file 'simplecell-nolib.g would be::

    sli_load simplecell-nolib.g
    delete /proto
    delete /output
    delete /library
    ndf_save /cell simplecell-nolib.ndf
    quit

Presently, the command ``ndf_save /cell`` or ``ndf_save /cell/**`` saves not
only the '/cell' element tree, but also the '/library' and the elements
created by default in GENESIS 2 '/proto' and '/output'.  These trees were
deleted before the models were saved.

The cell models in this collection are
--------------------------------------

*simplecell-nolib.ndf* - The basic two compartment 'simplecell'
model that is used in the tests in test-simplecell directory of::

  ~/neurospaces_project/ns-sli/source/snapshots/0/tests/scripts

and in the GENESIS Modeling Tutorial section "Building a cell the easy way"
(http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/simplecell-tut.html).

The soma compartment contains "squid-like" Na and K channels formed from
the channel prototype script 'hh_tchan.g' in GENESIS 2 neurokit/prototypes
library.  The gate tables of these channels are filled using the
'setupalpha' command with no added options.  The dendrite compartment
contains and excitatory synchan 'Ex_channel' and an inhibitory synchan
'Inh_channel'.  Because of its simplified morphology, this is useful model
for testing variations of GENESIS 2 scripting commands that are used in
more complex models, and testing their conversion to G-3.

*traub91-nolib.ndf* - The 'traub91' model is a burst-firing CA3 region
hippocampal pyramidal cell, using a linear arrangement of 19 compartments
containing active conductances in all compartments.

*traub94-nolib.ndf* - A burst-firing hippocampal pyramidal cell using 64
asymmetric compartments in a branched geometry, containing active
conductances in all compartments.  The channels are very similar to the
ones used in the 'traub91' model.

*traub95-nolib.ndf* - A fast spiking hippocampal interneuron, using 51
branched asymmetric compartments containing active conductances in all
compartments.

*RScell-nolib.ndf* - RScell is a single compartment cell used in the RSnet
simulation and GENESIS Modeling Tutorial section "Creating large networks
with GENESIS"
(http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/net-tut.html).

The channels used are GENESIS 2 adaptations of NEURON models by Destexhe
and Par (1999).  The functions defining the channels are implemented with a
straightforward use of setupalpha to create Na, K, and a muscarinic M
current.  'sli_run' and 'ndf_load' plus 'run' both give results that are
indistinguishable from GENESIS 2 when plotted.

*BDK5cell2-nolib.ndf* - The 'BDK5cell2' model is a branched layer 5
cortical pyramidal cell with 9 compartments and 9 voltage or calcium
activated channels in the soma.

The original version of this model can be found in the genesis-sim.org
Models archive under 'corticalcells' (http://genesis-sim.org/node/110).
The detailed description of the channel models and the fitting of
parameters was given by Bernander, Douglas and Koch (1992) in the
unpublished Caltech CNS Memo 16 (Bernander_etal_CNSmemo16_1992.pdf).

The original GENESIS 2 implementation used symmetric compartments and
filled the gate tahles by using the 'setuptau' command.  The 'BDKcell2'
model is a transformation using appropriately sized asymmetric compartments
to give equivalent passive properties.  The gate tables are filled using
'setupalpha'.  This version produces results consistent with the GENESIS 2
version.

Channel models
--------------

The 'channels' directory contains the files 'Na_hh_tchan.ndf' and
'K_hh_tchan.ndf'.  These represent the Hodgkin-Huxley squid fast Na
and delayed rectifier K channels used in the 'simplecell' model and
many tutorial scripts.  The files were generated with sli_load/ndf_save
in the same manner as the cell NDF files, with a SLI script that created
the two channels.  As with the cells, all other elements except the channel
to be saved were deleter before saving the channel to NDF.

