=========
= About = 
=========

ExpressPCB PCB (*.pcb) and schematic (*.sch) files (http://www.expresspcb.com/)
Sensor Front End for the apertus° Axiom Alpha camera prototype: http://axiom.apertus.org/index.php?site=alpha


===========
= Authors =
===========

Stuart  Allman - contact through apertus° contact form: http://apertus.org/contact
Sebastian Pichelhofer - contact through apertus° contact form: http://apertus.org/contact


========
= TODO =
========

-) double check the footprints (FMC connector seems correct, but the sensor socket should be checked)
-) turn off "snap to grid" feature and manually adjust the spacing on the LVDS pairs as per the schematic note. 
I usually do this by placing a silkscreen trace of the correct width and aligning the traces at the edge of the silkscreen.
-) check dimensions of the PCB and if we will get into the way of anything on the zedboard



=========
= NOTES =
=========

-) Set J18 on Zedboard for 1.8v operation!!!

-) Use Samtec VITA 57 FMC LPC connector with 10mm stack height - http://www.samtec.com/standards/vita.aspx part number: ASP-134604-01