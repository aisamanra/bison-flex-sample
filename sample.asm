# Our fake assembly syntax here uses line-oriented comments
# that start with a pound sign. All instructions names are
# valid, but register names have to start with 'r' and end
# with 'x'.

# instructions can have zero, one, or two arguments, and all
# must be followed by semicolons.

# A zero-argument instruction looks like

pop;

# A one-argument instruction looks like

push rax;

# A two-argument instruction looks like

add rnx, rqx;

# arguments can also include offsets, which must be hex literals
# and must be enclosed in parens:

mov raaaax, (rax+0x8);

# parens around other arguments without offsets are optional
push (rax);
