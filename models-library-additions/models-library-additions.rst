**Related Documentation:**

.. start: userdocs-tag-replace-items related-tutorial
.. end: userdocs-tag-replace-items related-tutorial

`Convert a GENESIS 2 Simulation to GENESIS 3
<../tutorial3/tutorial3.html>`_

`Creating GENESIS 3 Simulations with Python
<../tutorial-python-scripting/tutorial-python-scripting.html>`_

`Index of GENESIS 3 User Tutorials
<../tutorial-genesis/tutorial-genesis.html>`_

Some NDF files of converted GENESIS 2 models
============================================

This describes some GENESIS 2 single cell and channel models that have been
converted to G-3 NDF format for inclusion in the
'/usr/local/neurospaces/models/library' directory.  The list of model
categories may be seen with the g-shell command 'library_show'.  The cells
and channels are listed with the commands 'library_show ndf cells' and
'library_show ndf channels'.

Except as noted, NDF format files in the cells/ directory were produced
with the gshell 'sli_load" and 'ndf_save' commands from GENESIS 2 SLI
scripts that create a cell '/cell' from prototpe compartments in
'/library'. A typical set of commands to generate the file
'simplecell-nolib.g would be::

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

Also, NDF files generated in this manner have FORWARDPARAMETERS blocks that
are incompatible with their use with 'ndf_namespace_load'.  As noted below,
most of these files were then edited manually to replace FORWARDPARAMETERS
blocks with equivalent PARAMETERS blocks within the elements that are named
in the block.  In addition, the GROUP block was renamed CELL.  These
changes allow them to be used in network simulations, and gshell test
scripts have been provided to test them in a simple two cell network.  The
edited NDF files also have short versions of the model description in
comments at the beginning.

Cell models in this collection
------------------------------

With the exception of *squidcell.ndf*, all of these cell models have
synchans and spikegens to allow synaptic connections.  Unless noted,
they may be used in networks with the 'ndf_namespace_load' command.

*squidcell.ndf* - is based on the model of the squid giant axon segment
that was used in the original GENESIS 'Squid' tutorial by Mark Nelson
in 1989.  Recent versions of the tutorial scripts accompany the
GENESIS 2.3 distribution.  The 'cell' is a cylindrical segment with
length = diameter = 500 um, with the parameters that were
used in the original Hodgkin-Huxley model and the Squid tutorial.
The Hodgkin-Huxley Na and K channels are implemented as tabchannels.
Unlike the GENESIS 2 version, the G-3 NDF representation uses
SI units instead of physiological units, and sets the resting potential
to -0.070 volts, instead of zero.  This model will be used in future
G-3 versions of the Squid tutorial.

*simplecell.ndf* - The basic two compartment 'simplecell' model that is
used in many of the G-3 ns-sli and gshell test scripts, and in the GENESIS
2 Modeling Tutorial section `Building a cell the easy way
<http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/simplecell-tut.html>`_.
It also forms the basis of recent GENESIS 3 Python scripting tutorials,
e.g.  `Creating GENESIS 3 Simulations with Python
<../tutorial-python-scripting/tutorial-python-scripting.html>`_.

The soma compartment contains "squid-like" Na and K channels formed from
the channel prototype script 'hh_tchan.g' in the GENESIS 2
*neurokit/prototypes* library.  The gate tables of these channels are filled
using the 'setupalpha' command with no added options. The dendrite
compartment contains an excitatory synchan 'Ex_channel' and an inhibitory
synchan 'Inh_channel'.  Because of its simplified morphology, this is
useful model for testing variations of GENESIS 2 scripting commands that
are used in more complex models, and for testing their conversion to G-3.

*simplecell-nolib.ndf* is an older version, not suitable for networks.

*RScell.ndf* - RScell is a very simple one-compartment model of a
neocortical regular spiking pyramidal cell that is used in the *RSnet*
simulation.  This example simulation is described in the GENESIS 2 Modeling
Tutorial section `Creating large networks with GENESIS
<http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/genprog/net-tut.html>`_.
and the G-3 tutorial `Modeling Synaptic Connections and Large Networks with
G-3 <../tutorial-networks/tutorial-networks.html>`_.  The simplicity of the
cell model makes it suitable for use in large network models that need to
run quickly.

In addition to a fast sodium current and delayed rectifier potassium
current, the model uses a Muscarinic potassium current (KM) in order to
achieve spike frequency adaption.  The GENESIS implementation by David
Beeman is based on the NEURON demonstration 'FLUCT' by Alain Destexhe, as
described by Destexhe, et al. (2001).  This uses channel models by Destexhe
and Par (1999), which use modified Traub and Miles (1991) sodium and
potassium conductances, and a muscarinic potassium 'M current' from Mainen
and Sejnowski (1996).  These are implemented in GENESIS 2 and 3 as
tabchannels with a 'setupalpha' parameterized form to represent the
channel rate parameters.

*RScell-nolib2.ndf* is an older equivalent version, without comments.

*RScell-nolib.ndf* is an older version, not suitable for networks.

*VA_HHcell.ndf* - The GENESIS implementation by David Beeman of the model
cell that was used as a benchmark for neural simulators in the review by
Brette et al.  (2007).  This is a dual exponential conductance version of
the the Vogels and Abbott (2005) model with single compartment neurons
having Hodgkin-Huxley dynamics.  The fast sodium conductance Na_traub_mod
and non-inactivating potassium conductance K_traub_mod are the same as
those used in *RScell*.  The GENESIS 2 version of the benchmark can be
found on `ModelDB
<http://senselab.med.yale.edu/modeldb/showmodel.asp?model=83319>`_ and at
`http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/networks/Vogels-Abbott_net
<http://www.genesis-sim.org/GENESIS/UGTD/Tutorials/networks/Vogels-Abbott_net>`_.

*BDK5cell2.ndf* - The 'BDK5cell2' model is a branched layer 5
cortical pyramidal cell with 9 compartments and 9 voltage or calcium
activated channels in the soma.  This large variety of conductances
makes the model a good candidate for improved fits to experiment
using automated parameter searches.

The morphology and passive parameters are based on the reduced neocortical
pyramidal cell models of Bush and Sejnowski (1993).  These are simplified
models of much larger (about 400 compartment) models of pyramidal cells
from area 17 of cat visual cortex (Koch, Douglas and Wehmeier 1990;
Bernander, et al. 1991).  A collapsing method was used that conserves the
axial resistance and makes some adjustments in the passive membrane
parameters in order to faithfully reproduce the electrical responses of the
larger models.

A detailed description of the channel models and the fitting of parameters
that were used in the GENESIS implementation by David Beeman is given by Bernander,
Douglas and Koch (1992) in the unpublished `Caltech CNS Memo 16 (large PDF)
<figures/Bernander_etal_CNSmemo16_1992.pdf>`_.

The implementation of the passive morphology used in *BDK5cell2* has
asymmetric compartments instead of the symmetric compartments of the Bush
and Sejnowski model.  This is done by setting the axial resistance to be
the average of the original value and that of the 'child' compartment to
which it is connected.  The original values of the 'specific' passive
parameters RM, RA, CM, which do not depend on the compartment dimensions,
and the channel conductance densities are preserved by a transformation
that alters the length and diameter of each compartment to keep the surface
area the same and to yield the desired axial resistance.

This transformation of the cell morphology produces a slight shortening of
the dendrites, but no detectable changes in the passive properties.  The
resulting cell has an input resistance of 47 Mohm and a membrane time
constant of 10 msec, as does the original version with symmetric
compartments.  The total apical dendrite length is reduced from 150 um to
975 um, the length of the oblique dendrite from 150 um to 125 um, and the
total length of basal dendrites from 200 um to 180 um in the asymmetric
model. The gate tables are filled using 'setupalpha'.  This version
produces results consistent with the GENESIS 2 version.

The original version of this model can be found in the genesis-sim.org
`Models archive <http://genesis-sim.org/models>`_ under 'corticalcells'.

*deep_pyrcell.ndf* - This represents a simplified deep pyramidal cell from
the thalamorecipient layer of primary auditory cortex (AI).  The model,
implemented by David Beeman (GENESIS 2 version April 2010; G-3 version Sept
2012), uses a morphology based on the Bush and Sejnowski (1993) reduced 9
compartment layer 5 cat pyramidal cell from visual cortex that was used in
*BDK5cell2*.

The voltage activated channels used here are a small set of modified Traub
et al. (1991) hippocampal CA3 region channels with activation and
inactivation time constants scaled to give dynamics typical of neocortical
cells.	Parameter searches were performed manually and with the GENESIS 2
parameter search library simulated annealing method (Vanier and Bower,
1999) to approximately fit current clamp results by Nowak et al. (2003)
for regular spiking cells in cat visual cortex, and by Hefti and Smith
(2000) for rat layer V primary auditory cortex.

The channels used are::

    Na_pyr             Fast sodium
    Kdr_pyr	       Potassium delayed rectifier
    Ca_hip_traub91     High threshold calcium channel
    Kahp_pyr	       Potassium AHP channel dependent on Ca concentration
    Ca_conc            concentration element to convert Ca current to [Ca]

The firng patterns under current clamp conditiions show firing rates and
spike frequency adaptation typical of neocortical deep pyramidal cells.
However, as with most simple models involving only a subset of the channels
that have been found in cortical neurons, the latency to the first spike
after current injection is shorter than that seen experimentally.

*baskcell.ndf* - 'baskcell' is a very simple 'ad hoc' model of a fast
spiking inhibitory neocortical interneuron, such as a basket cell,
implemented by David Beeman (August 2008).  The 30 um soma contains fast
sodium and delayed rectifier potassium conductances, and an inhibitory GABA
synaptic conductance.  The single 200 x 2 um dendritic cylinder contains an
excitatory AMPA synaptic conductance.  The input resistance of the cell is
113 Mohm, with a membrane time constant of 10 msec.  The sodium and
potassium conductances were derived from the the Destexhe and Par (1999)
model that was used in *RScell*, using parameters obtained with parameter
searches using the GENESIS 2 'param' library. These produced rough
agreement with spike frequency vs. current injection measurements of fast
spiking cells in cat visual cortex by Nowak, et al. (2003).

The test scripts
----------------

The test scripts for the models described above are in the directory
~/neurospaces_project/gshell/source/snapshots/0/tests/scripts/

They are executed within that directory using the command::

    genesis-g3 <script-name>

All of them produce output to a file '/tmp/output'.

*test-squidcell.g3* - Performs a 'ndf_load' of *squidcell.ndf* and
plots the Na activation and inactication variables
(state_m and state_h) and the K activation (state_n) during a steady
current injection of 100 nA.

The following tests are based on the 'two-cells.g3' script that is
described in the tutorial `Modeling Synaptic Connections and Large Networks
with G-3 <../tutorial-networks/tutorial-networks.html>`_.  In each case,
cell 1 has a steady injection current, and soma action potentials
generate spikegen events that are passed to cell 2 via a synaptic
connection to the synchan Ex_channel. The connection between the cells uses
a very large (30 msec) propagation delay in order to easily see the effect.
This simple circuit is created by loading the cell model into a namespace
with 'ndf_namespace_load', creating copies for the two cells, and creating
a connection within a 'projection' element, as described in the tutorial.
If the simulation is running correctly, the second cell will begin firing
slightly after 30 msec of run time.  The tutorial version uses *RScell.ndf*.

*two-baskcells.g3* - test of *baskcell.ndf*

*two-BDK5cells.g3* - test of *BDK5cell2.ndf*

*two-pyrcells.g3* - test of *deep_pyrcell.ndf*

*two-simplecells.g3* - test of *simplecell.ndf*

*two-VAcells.g3* - test of *VA_HHcell.ndf*

*two-cells1.g3* - test of *RScell-nolib2.ndf*

Cell models not yet converted for networks
------------------------------------------

*traub91-nolib.ndf* - The *traub91* model is a burst-firing CA3 region
hippocampal pyramidal cell, using a linear arrangement of 19 compartments
containing active conductances in all compartments.  The original GENESIS 2
model is distributed with GENESIS 2.3.  It is based upon the paper by
Traub et al. (1991).

*traub94-nolib.ndf* - A burst-firing hippocampal pyramidal cell using 64
asymmetric compartments in a branched geometry, containing active
conductances in all compartments.  The channels are very similar to the
ones used in the *traub91* model.  The model is based on the paper by Traub
et al. (1994) and was implemented by Pulin Sampat (Brandeis University) and
Patricio Huerta (MIT) with help from Dr. Roger Traub.  A fuller
description is given in the genesis-sim.org `Models archive
<http://genesis-sim.org/models>`_.

*traub95-nolib.ndf* - A fast spiking hippocampal interneuron, using 51
branched asymmetric compartments containing active conductances in all
compartments.  The model is based in the paper by Traub and Miles (1995) and
was implemented by Eliot Menschik. This, and the *traub94* model pyramidal
cell were used in the papers by Menschik and Finkel (1998, 1999).
A fuller description is given in the genesis-sim.org `Models archive
<http://genesis-sim.org/models>`_.

Channel models
--------------

The 'channels' directory contains the files 'Na_hh_tchan.ndf' and
'K_hh_tchan.ndf'.  These represent the Hodgkin-Huxley squid fast Na
and delayed rectifier K channels used in the *simplecell* model and
many tutorial scripts.  The files were generated with sli_load/ndf_save
in the same manner as the cell NDF files, with a SLI script that created
the two channels.  As with the cells, all other elements except the channel
to be saved were deleted before saving the channel to NDF.

References
----------

Bernander O, Douglas RJ, Martiin AC, Koch C (1991) Synaptic background
activity influences spatiotemporal integration in single pyramidal cells.
Proc. Natl. Acad. Sci. 88:11569-11573.

Bernander O, Douglas RJ, Koch C (1992) A model of regular-firing cortical
pyramidal neurons, CNS Memo 16, Caltech

Brette R, Rudolph M, Carnevale T, Hines M, Beeman D, Bower JM, Diesmann M,
Morrison A, Goodman PH, Harris Jr FC, Zirpe M, Natschlager T, Pecevski D,
Ermentrout B, Djurfeldt M, Lansner A, Rochel O, Vieville T, Muller E,
Davison AP, El Boustani S, and Destexhe A (2007) Simulation of networks of
spiking neurons: a review of tools and strategies. J. Comput. Neurosci.
23: 349-398.

Bush PC and Sejnowski TJ (1993) Reduced compartmental models of
neocortical pyramidal cells, J. Neurosci. Methods 46:159-166.

Bush PC and Sejnowski TJ (1996) Inhibition synchronizes sparsely
connected cortical neurons within and between columns in realistic
network models, J. Comput. Neurosci. 3:91-110.

Destexhe A and Par D (1999) Impact of network activity on the
integrative properties of neocortical pyramidal neurons in vivo.
J. Neurophysiol. 81: 1531-1547.

Destexhe A, Rudolph M, Fellous JM and Sejnowski TJ (2001)
Fluctuating synaptic conductances recreate in-vivo-like activity in
neocortical neurons. Neuroscience 107: 13-24.

Hefti BH and Smith PH (2000) Anatomy, Physiology, and Synaptic Responses of
Rat Layer V Auditory Cortical Cells and Effects of Intracellular GABAA
Blockade.  J. Neurophysiol. 83:2626-2638.

Koch C, Douglas RJ and Wehmeier U (1990) Visibility of synaptically
induced conductance changes: theory and simulations of anatomically
characterized cortical pyramidal cells. J. Neurosci. 10:1728-1744.

Mainen ZF and Sejnowski TJ (1996) Influence of dendritic structure on
firing pattern in model neocortical neurons. Nature 382:363-366.

Menschik ED and Finkel L H (1998) Neuromodulatory control of
hippocampal function: Towards a model of Alzheimer's disease. Artificial
Intelligence in Medicine 13:99-121.

Menschik ED and Finkel LH (1999) Cholinergic neuromodulation and
Alzheimer's disease: from single cells to network simulations. Progress in
Brain Research, 121:19-45.

Nowak LG, Azouz R, Sanchez-Vives MV, Gray CM and McCormick DA (2003)
Electrophysiological classes of cat primary visual cortical
neurons in vivo as revealed by quantitative analyses.
J. Neurophysiol. 89:1541-1566.

Traub RD and Miles R (1991) Neuronal Networks of the hippocampus.
Cambridge University Press.

Traub RD, Wong RKS, Miles R, Michelson H. (1991) A Model of a CA3
Hippocampal Neuron Incorporating Voltage-Clamp Data on Intrinsic
Conductances.  Neurophysiol. 66:635-650.

Traub RD, Jefferys JG, Miles R, Whittington MA and Toth K (1994)
A branching dendritic model of a rodent CA3 pyramidal neurone.
J Physiol. 481:79-95.

Traub RD and Miles R (1995) Pyramidal cell-to-inhibitory cell spike
transduction explicable by active dendritic conductances in inhibitory
cell.  J Comput Neurosci. 2:291-298.

Vanier MC and Bower JM (1999) A Comparative Survey of Automated
Parameter-Search Methods for Compartmental Neural Models.
J. Computat. Neurosci. 7:149-171.

Vogels TP and Abbott LF (2005) Signal propagation and logic gating in
networks of integrate-and-fire neurons. J. Neurosci. 25: 10786-10795.

