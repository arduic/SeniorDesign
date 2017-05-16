function [s]=vhdl_int_arr(vec)
    s = strrep(mat2str(vec), ' ', ',');
    s = strrep(s, '[', '(');
    s = strrep(s, ']', ')');
end