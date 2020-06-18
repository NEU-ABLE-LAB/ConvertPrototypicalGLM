# ConvertPrototypicalGLD
Converts prototypical distribution feeders from [GridLAB-D](https://www.gridlabd.org/) .glm files to [MATLAB](https://www.mathworks.com/products/matlab.html) digraph objects. Digraph objects are generated for full and simplified representation.

## Quick Start
1. [Download](https://github.com/gridlab-d/Taxonomy_Feeders) prototypical feeder .glm files. Add all 24 .glm files to the "\glm" folder.
2. Run ###. This generates ### files in ###.
3. Run ###. This generates ### files in ###.
4. Visualize simplified models using ###.

## Overview of Prototypical Feeders
This converts prototypical feeders established by Schneider, et al. in [Modern Grid Initiative Distribution Taxonomy Final Report](https://www.osti.gov/biblio/1040684-modern-grid-initiative-distribution-taxonomy-final-report) as part of work by Pacific Northwest National Laboratory (PNNL) on behalf of the Department of Energy.

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
Prototypical feeders .glm files are available at https://sourceforge.net/p/gridlab-d/code/HEAD/tree/Taxonomy_Feeders/. Files downloaded on 19 September 2019 are included in the folder "\glm".

These files 

# GridLAB-D Syntax and Data

# Conversion Goals

Files are made available with node and edge lists for visualization in NodeXL. These files include relationships but do not include node or edge properties.

## Relevant Components and Properties
Many feeders include normally open switches that provide the ability to transfer load from other feeders, and vice versa.

Overhead and underground

## Not Relevant Components and Properties
Feeder descriptions include the percent loading on the system. This reflects the connected load and the feeder ratings. This is not considered; all distribution feeders are treated as sufficient for all operating scenarios.

Electrical characteristics, e.g. power quality, phase balancing, voltage regulation.

## OPEN QUESTIONS
- Are switches considered fused? Doesn't look like it.
- Impact of reclosers
- Load class categories (residential, commerical, industrial)

- Download from github page, verify works, update link above

## Process
To repeat this analysis:
1. Clear the folder "\results"
2. Run parseGLM to convert each .glm into a string array
3. Run convertGLM to convert string array into graph() objects
...more to come...


- Create quick start guide at top
- This has only been tested with prototypical feeder files (from commit date 6 Jan 20). Other GridLAB-D files may include syntax, properties, or relationships not covered by this glm2net().
