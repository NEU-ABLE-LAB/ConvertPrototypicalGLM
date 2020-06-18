# ConvertPrototypicalGLD
Converts prototypical distribution feeders from [GridLAB-D](https://www.gridlabd.org/) .glm files to [MATLAB](https://www.mathworks.com/products/matlab.html) digraph objects. Digraph objects are generated for full and simplified representation. Note: this has only been tested with prototypical feeder files. Other GridLAB-D files may include syntax, properties, or relationships not addressed by this code.

## Quick Start
Output files provided in _\output_ and _\simple_ folders. Visualize simplified graphs with plotSimple.m.

To generate files independently:
1. Clear _\output_ and _\simple_ folders
2. [Download](https://github.com/gridlab-d/Taxonomy_Feeders) prototypical feeder .glm files. Add all 24 .glm files to the _\glm_ folder.
3. Run convertGLM to generate 24 files in "\output"
4. Run simplifyAll to generate 24 files in "\simple"

### Output Graphs
Each .mat file in _\output_ includes string _modelName_ and digraph _G_.

### Simple Graphs
Each .mat file in _\simple_ includes string _modelName_ and digraph _G_.

## Overview of Prototypical Feeders
This converts prototypical feeders described by Schneider, et al. in [Modern Grid Initiative Distribution Taxonomy Final Report](https://www.osti.gov/biblio/1040684-modern-grid-initiative-distribution-taxonomy-final-report) as part of work by Pacific Northwest National Laboratory (PNNL) on behalf of the Department of Energy.

PNNL collected distribution feeder models from electric utilities around the nation. They identified regional differences in design and operation, then established a taxonomy of 24 prototypical feeder models that "contain the fundamental characteristics of non-urban core, radial distribution feeders from the various regions of the U.S." By eliminating proprietary and system-specific information, their models can be used freely. The models are provided in the .glm format for use in the GridLAB-D simulation environment.

### Classification Categories
Major classification was by climate region and voltage level.

Climate regions 1-5 match the DOE handbook for design guidance for energy-efficient small office buildings:
1. West coast; temperate climate
2. North central and northeast; cold climate
3. Southwest; hot and arid climate
4. Non-coastal southeast and central; hot and cold climate
5. Southeast; hot and humid climate

Voltage levels represent the nearest common level (e.g. 12.00 kV is grouped with 12.47 kV):
1. 12.47 kV (included in all 5 regions)
2. 25 kV (included in 4 regions)
3. 35 kV (included in 2 regions)

An additional 35 characteristics were considered, including: feeder rating and properties, connected residential and commercial load, and length overhead and underground. Clustering analysis further divided the 12.47 kV feeders in each region. For each cluster, PNNL generated a representative feeder model. An additional "general category" model was developed to represent a climate-agnostic feeder supporting 1 or 2 very large industrial or commerical loads.

### Summary of Feeders
| Name		| kV	| kVA	| Description 						|
|-----------|-------|-------|-----------------------------------|
|R1-12.47-1	|12.5	|7152	|Moderate suburban and rural		|
|R1-12.47-2	|12.47	|2836	|Moderate suburban and light rural	|
|R1-12.47-3	|12.47	|1362	|Small urban center					|
|R1-12.47-4	|12.47	|5334	|Heavy suburban						|
|R1-25.00-1	|24.9	|2105	|Light rural						|
|R2-12.47-1	|12.47	|6046	|Light urban						|
|R2-12.47-2	|12.47	|6098	|Moderate suburban					|
|R2-12.47-3	|12.47	|1411	|Light suburban						|
|R2-25.00-1	|24.9	|17021	|Moderate urban						|
|R2-35.00-1	|34.5	|8893	|Light rural						|
|R3-12.47-1	|12.47	|8417	|Heavy urban						|
|R3-12.47-2	|12.47	|4322	|Moderate urban						|
|R3-12.47-3	|12.47	|7880	|Heavy suburban						|
|R4-12.47-1	|13.8	|5530	|Heavy urban with rural spur		|
|R4-12.47-2	|12.5	|2218	|Light suburban and moderate urban	|
|R4-25.00-1	|24.9	|948	|Light rural						|
|R5-12.47-1	|13.8	|9430	|Heavy suburban and moderate urban	|
|R5-12.47-2	|12.47	|4500	|Moderate suburban and heavy urban	|
|R5-12.47-3	|13.8	|9200	|Moderate rural						|
|R5-12.47-4	|12.47	|7700	|Moderate suburban and urban		|
|R5-12.47-5	|12.47	|8700	|Moderate suburban and light urban	|
|R5-25.00-1	|22.9	|12050	|Heavy suburban and moderate urban	|
|R5-35.00-1	|34.5	|11800	|Moderate suburban and light urban	|
|GC-12.47-1	|12.47	|5200	|Single large commercial or industrial|

## File Access
Prototypical feeders .glm files are available at https://github.com/gridlab-d/Taxonomy_Feeders. Code tested on files from commit 9c88d1a on Jan 6.

# GridLAB-D Syntax and Data

# Conversion Goals

Files are made available with node and edge lists for visualization in NodeXL. These files include relationships but do not include node or edge properties.

## Relevant Components and Properties
**Names** for nodes and edges are provided for each .glm object. When edges are created to link a parent object with its child, the edge is named after the child with "parent-" as a prefix.



Many feeders include normally open switches that provide the ability to transfer load from other feeders, and vice versa.

Overhead and underground

## 

**Recorder** objects are not included in either digraph

## Not Relevant Components and Properties
Feeder descriptions include the percent loading on the system. This reflects the connected load and the feeder ratings. This is not considered; all distribution feeders are treated as sufficient for all operating scenarios.

Electrical characteristics, e.g. power quality, phase balancing, voltage regulation.



**Meter** objects

# Conversion Process and Details
## Translate .glm files to string arrays with parseGLM()
First, copy .glm files to 

## 


## OPEN QUESTIONS
- Are switches considered fused? Doesn't look like it.
- Impact of reclosers
- Load class categories (residential, commerical, industrial)

- Download from github page, verify works, update link above


- 


## Node Types with Properties
(Unless denoted otherwise, properties not included in simple representation)

**capacitor**
1.	cap_nominal_voltage
2.	capacitor_A/B/C
3.	control
4.	control_level
5.	dwell_time
6.	nominal_voltage
7.	parent: incorporated as edge
8.	phases
9.	phases_connected
10.	pt_phase
11.	switchA/B/C
12.	time_delay
13.	voltage_set_high
14.	voltage_set_low

**load**
1.	constant_power_A/B/C: absolute values (kVA) summed and retained
2.	load_class
3.	nominal_voltage
4.	parent: incorporated as edge
5.	phases
6.	voltage_A/B/C

**meter**
1.	nominal_voltage
2.	phases
3.	voltage_A/B/C

**node**
1.	bustype: used to identify source node
2.	nominal_voltage
3.	parent: incorporated as edge
4.	phases
5.	voltage_A/B/C

**triplex_meter**
1.	nominal_voltage
2.	phases
3.	voltage_1/2/N

**triplex_node**
1.	nominal_voltage
2.	parent: incorporated as edge
3.	phases
4.	power_12: absolute value (kVA) retained
5.	voltage_1/2/N

## Edge Types with Properties
(Unless denoted otherwise, properties not included in simple representation)

**fuse**: converted to node
1.	current_limit
2.	mean_replacement_time
3.	phases
4.	status

**overhead_line**
1.	configuration
2.	configuration_conductor_A/B/C/N
3.	configuration_conductor_A/B/C/N_geometric_mean_radius
4.	configuration_conductor_A/B/C/N_rating_summer_continuous
5.	configuration_conductor_A/B/C/N_resistance
6.	configuration_spacing
7.	configuration_spacing_distance_AB/AC/AN/BC/BN/CN
8.	length
9.	phases

**recloser**: converted to node
1.	max_number_of_tries
2.	numer_of_tries
3.	phase_A/B/C_state
4.	phases
5.	retry_time
6.	status

**regulator**: converted to node
1.	configuration
2.	configuration_Control
3.	configuration_band_center
4.	configuration_band_width
5.	configuration_connect_type
6.	configuration_lower_taps
7.	configuration_raise_taps
8.	configuration_regulation
9.	configuration_tap_pos_A/B/C
10.	configuration_time_delay
11.	phases

**switch**: converted to node
1.	phases
2.	status

**transformer**: converted to node
1.	configuration
2.	configuration_connect_type
3.	configuration_install_type
4.	configuration_powerA/B/C_rating
5.	configuration_power_rating
6.	configuration_primary_voltage
7.	configuration_reactance
8.	configuration_resistance
9.	configuration_secondary_voltage
10.	configuration_shunt_impedance
11.	phases

**triplex_line**
1.	configuration
2.	configuration_conductor_1/2/N
3.	configuration_conductor_1/2/N_geometric_mean_radius
4.	configuration_conductor_1/2/N_resistance
5.	configuration_diameter
6.	configuration_insulation_thickness
7.	length
8.	phases

**underground_line**
1.	configuration
2.	configuration_conductor_A/B/C/N
3.	configuration_conductor_A/B/C/N_conductor_diameter
4.	configuration_conductor_A/B/C/N_conductor_gmr
5.	configuration_conductor_A/B/C/N_conductor_resistance
6.	configuration_conductor_A/B/C/N_neutral_diameter
7.	configuration_conductor_A/B/C/N_neutral_gmr
8.	configuration_conductor_A/B/C/N_neutral_resistance
9.	configuration_conductor_A/B/C/N_neutral_strands
10.	configuration_conductor_A/B/C/N_outer_diameter
11.	configuration_conductor_A/B/C/N_rating_summer_continuous
12.	configuration_conductor_A/B/C/N_shield_gmr
13.	configuration_conductor_A/B/C/N_shield_resistance
14.	configuration_spacing
15.	configuration_spacing_distance_AB/AC/AN/BC/BN/CN
16.	length
17.	phases


