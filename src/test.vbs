class a private a 
sub abc 
a = 1 end sub 
public function xyz 
xyz = a end function end class
class b private b 
public sub abc1 
b = 1 end sub 
function xyz1 
xyz = b end function end class
function out1 
out1 = b end function
set a1 = new a
a1.abc
Wscript.Echo a1.xyz