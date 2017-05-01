#!/usr/bin/env python
import math

#My attempt at a python script to generate the LUT for the transmitter.
#Supposedly it's going to change all the time so this script should make creating the LUT file less painful.

def num2Step(value,numSteps):
	stepVal=-1*math.pi/2
	step=0
	while math.fabs(stepVal-float(value))>math.pi/(numSteps*4):
		stepVal+=math.pi/numSteps
		step+=1

	return str(step)

#Grab the initial data
block = []
fM = open('simulationResults.csv')
fM.readline()
for index,line in enumerate(fM):
	block.append(line.split(','))
fM.close()

#Basic file stuff not pertaining to the LUT that will always be there
f = open('lut_core.vhd', 'w')


f.write('library IEEE;\n')
f.write('use IEEE.STD_LOGIC_1164.ALL;\n\n')

f.write('entity lut_core is\n')
f.write('    Generic (\n')
f.write('        num_rows : integer :=128;\n')
f.write('        num_cols : integer :=128;\n')
f.write('        num_theta_angles : integer := 216;\n')   #So the angles are floating points but they have to be indexed by this. As such they go 215-0. I need another table to translate that. And select it logically by taking angles*1000. Right now i'm having the LUT also in here just returning the angle selected
f.write('        num_phi_angles : integer :=3\n')    #I was told 3 is a normal number so f it
f.write('    );\n')
f.write('  Port ( \n')
f.write('    clk : in std_logic;\n')     #Used to signal when to update the LUT values. Doesn't mean the values actually change that's based on the request
f.write('    requested_row : in integer;\n')
f.write('    requested_col : in integer;\n')
f.write('    requested_theta : in integer;\n')
f.write('    requested_phi : in integer;\n')
f.write('    necessary_voltage_psi0 : out integer;\n') #The voltages will be returned in terms of steps on a DAC and not actual voltages.
f.write('    necessary_voltage_psi1 : out integer;\n')
f.write('    necessary_voltage_psi2 : out integer;\n')
f.write('    necessary_voltage_psi3 : out integer;\n')
f.write('    necessary_voltage_psi4 : out integer;\n')
f.write('    returned_theta_ang : out integer\n')
f.write('  );\n')
f.write('end lut_core;\n\n')

f.write('architecture Behavioral of lut_core is\n\n')

#The LUT structures as I currently have defined them
f.write('type voltage_LUT is array (num_rows-1 downto 0, num_cols-1 downto 0, num_theta_angles-1 downto 0, num_phi_angles-1 downto 0) of integer range 0 to 256;\n')
f.write('type theta_LUT is array (num_theta_angles-1 downto 0) of integer;\n\n')

f.write('constant psi0_volt_LUT : voltage_LUT :=(\n')
f.write('(15 => (7 => (')
for index,line in enumerate(block):
	f.write(str(index)+' => (others => '+num2Step(block[index][0],256)+'), \n')
f.write('others => (others => 0)), others => (others => (others => 0))),\n')
f.write('others => (others => (others => (others => 0))))\n')
f.write(');\n')

#f.write('signal psi1_volt_LUT : voltage_LUT :=(\n')
#f.write('(others => (others => (others => (others => 0))))\n')
#f.write(');\n')

f.write('constant psi1_volt_LUT : voltage_LUT :=(\n')
f.write('(15 => (7 => (')
for index,line in enumerate(block):
	f.write(str(index)+' => (others => '+num2Step(block[index][1],256)+'), \n')
f.write('others => (others => 0)), others => (others => (others => 0))),\n')
f.write('others => (others => (others => (others => 0))))\n')
f.write(');\n')

f.write('constant psi2_volt_LUT : voltage_LUT :=(\n')
f.write('(15 => (7 => (')
for index,line in enumerate(block):
	f.write(str(index)+' => (others => '+num2Step(block[index][2],256)+'), \n')
f.write('others => (others => 0)), others => (others => (others => 0))),\n')
f.write('others => (others => (others => (others => 0))))\n')
f.write(');\n')

f.write('constant psi3_volt_LUT : voltage_LUT :=(\n')
f.write('(15 => (7 => (')
for index,line in enumerate(block):
	f.write(str(index)+' => (others => '+num2Step(block[index][3],256)+'), \n')
f.write('others => (others => 0)), others => (others => (others => 0))),\n')
f.write('others => (others => (others => (others => 0))))\n')
f.write(');\n')

f.write('constant psi4_volt_LUT : voltage_LUT :=(\n')
f.write('(15 => (7 => (')
for index,line in enumerate(block):
	f.write(str(index)+' => (others => '+num2Step(block[index][4],256)+'), \n')
f.write('others => (others => 0)), others => (others => (others => 0))),\n')
f.write('others => (others => (others => (others => 0))))\n')
f.write(');\n')

f.write('constant my_theta_LUT: theta_LUT :=(')
for index,line in enumerate(block):
	f.write(str(index)+' => '+str(int(math.floor(float(block[index][6])*1000.0)))+', ')
f.write('others=>0);\n')

f.write('begin    \n')
    #The updater thing that actually sends the values from the LUT
f.write('    updater : process(clk) begin\n')
f.write('        if rising_edge(clk) then\n')
f.write('            necessary_voltage_psi0 <= psi0_volt_LUT(requested_row,requested_col,requested_theta,requested_phi);\n')
f.write('            necessary_voltage_psi1 <= psi1_volt_LUT(requested_row,requested_col,requested_theta,requested_phi);\n')
f.write('            necessary_voltage_psi2 <= psi2_volt_LUT(requested_row,requested_col,requested_theta,requested_phi);\n')
f.write('            necessary_voltage_psi3 <= psi3_volt_LUT(requested_row,requested_col,requested_theta,requested_phi);\n')
f.write('            necessary_voltage_psi4 <= psi4_volt_LUT(requested_row,requested_col,requested_theta,requested_phi);\n')
f.write('            returned_theta_ang <= my_theta_LUT(requested_theta);\n')
f.write('        end if;\n')
f.write('    end process;\n\n')
    
    #The actual LUT values
    #Example syntax on how to load
    #psi_volt_LUT(row,col,theta,angle) <= 4;
    #psi0_volt_LUT(1,2,3,4) <= 4;


	#Origonally I was worried that people could request angles not in the table. My new method is the table has an index range. You are just told what angle you requested when you make the request

#Converter of MATLAB result to VHDL LUT
#For now I am just going to use code that has a static row,col,and phi with a ranging theta. Although in real full code it would obviouslly need all 4 of those things. Which would take forever.


#fM = open('simulationResults.csv')
#fM.readline()	#Skip the label row
#for index,line in enumerate(fM):
	#Psi angles in terms of DAC steps for voltages
#	tmp=line.split(',')
#	tmpS='    psi0_volt_LUT(15,7,'+str(index)+',1) <= '+num2Step(tmp[0],256)+';\n'
#	f.write(tmpS)

#	tmpS='    psi1_volt_LUT(15,7,'+str(index)+',1) <= '+num2Step(tmp[1],256)+';\n'
#	f.write(tmpS)

#	tmpS='    psi2_volt_LUT(15,7,'+str(index)+',1) <= '+num2Step(tmp[2],256)+';\n'
#	f.write(tmpS)

#	tmpS='    psi3_volt_LUT(15,7,'+str(index)+',1) <= '+num2Step(tmp[3],256)+';\n'
#	f.write(tmpS)

#	tmpS='    psi4_volt_LUT(15,7,'+str(index)+',1) <= '+num2Step(tmp[4],256)+';\n'
#	f.write(tmpS)

	#Theta angle returned
#	tmpS='    my_theta_LUT('+str(index)+') <= '+str(int(math.floor(float(tmp[6])*1000.0)))+';\n\n'
#	f.write(tmpS)



f.write('end Behavioral;')
f.close()
