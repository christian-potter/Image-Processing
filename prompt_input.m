function [inputstr] = prompt_input()


titleinput= ['Select Option:',char(10)]; 
a = ['A: Reclassify Excitatory',char(10)]; 
s = ['S: Reclassify Inhibitory',char(10)]; 
d = ['D: Reclassify Projection',char(10)]; 
f = ['F: Reclassify Uncertain',char(10)]; 
q = ['Q: Go To Next Plane',char(10)]; 
w = ['W: Go to Previous Plane',char(10)]; 

f = ['Z: Change Image Brightness',char(10)]; 

inputstr= [titleinput,a,s,d,f,q,w]; 