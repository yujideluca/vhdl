library IEEE;
library numeric_std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity mux2bits is
    port(
        entr_0 : in unsigned(1 downto 0);
        entr_1 : in unsigned(1 downto 0);
        entr_2 : in unsigned(1 downto 0);
        entr_3 : in unsigned(1 downto 0);
        selection_bits : in unsigned(1 downto 0);
        mux_out : out unsigned(1 downto 0)
        );
        
end entity;

entity alu is
    port(
        x,y,count : in unsigned(7 downto 0);
        alu_sel : in unsigned(1 downto 0);
        alu_out : out unsigned(7 downto 0);
        carry_out, count_carry : out unsigned(6 downto 0)
        );
end entity;

architecture arch_mux2bits of mux2bits is
begin
    mux_out <=     entr_0 when selection_bits="00" else
                   entr_1 when selection_bits="01" else
                   entr_2 when selection_bits="10" else
                   entr_3 when selection_bits="11" else
                   "00";
end architecture;

architecture arch_alu of alu is
begin
    process(x,y,alu_sel)
    begin
        case(alu_sel) is
            when "00" =>
                alu_out(0) <= x(0) XOR y(0);
                carry_out(0) <= x(0) AND y(0);
                for sum in 0 to 6 loop
                    alu_out(sum_ind) <= (carry_out(sum_ind) AND x(sum_ind) AND y(sum_ind)) 
                                     OR (NOT(carry_out(sum_ind)) AND NOT(x(sum_ind)) AND y(sum_ind))
                                     OR (carry_out(sum_ind) AND NOT(x(sum_ind)) AND NOT(y(sum_ind)))
                                     OR (carry_out(sum_ind) AND x(sum_ind) AND NOT(y(sum_ind)));
                    carry_out(sum_ind+1) <= (carry_out(sum_ind) AND x(sum_ind))
                                     OR (carry_out(sum_ind) AND y(sum_ind))
                                     OR (x(sum_ind) AND y(sum_ind));
                    end loop;   
            when "01" =>
                for neg_ind in 0 to 7 loop --loop for negativating the value
                    if (y(neg_ind) = 1) then
                        y(neg_ind) <= '0';
                        end if;
                    if (y(neg_ind) = 0) then
                        y(neg_ind) <= '1';
                        end if;
                    end loop;
                alu_out(0) <= x(0) XOR y(0);
                carry_out(0) <= x(0) AND y(0);
                for sub_ind in 0 to 6 loop
                    alu_out(sub_ind) <= (carry_out(sub_ind) AND x(sub_ind) AND y(sub_ind)) 
                                     OR (NOT(carry_out(sub_ind)) AND NOT(x(sub_ind)) AND y(sub_ind))
                                     OR (carry_out(sub_ind) AND NOT(x(sub_ind)) AND NOT(y(sub_ind)))
                                     OR (carry_out(sub_ind) AND x(sub_ind) AND NOT(y(sub_ind)));
                    carry_out(sub_ind+1) <= (carry_out(sub_ind) AND x(sub_ind))
                                     OR (carry_out(sub_ind) AND y(sub_ind))
                                     OR (x(sub_ind) AND y(sub_ind));
                    end loop;
            when "10" => --multiplication
                for multi in 0 to to_integer(y) loop
                    alu_out(0) <= x(0) XOR y(0);
                    carry_out(0) <= x(0) AND y(0);
                    for mult_ind in 0 to 6 loop
                        alu_out(mult_ind) <= (carry_out(mult_ind) AND NOT(x(mult_ind)))
                                          OR (carry_out(mult_ind) AND x(mult_ind));
                        carry_out(mult_ind+1) <= x(mult_ind);
                        end loop;
                    end loop;

            when "11" =>  --division
                for neg_div in 0 to 7 loop
                    if (y(neg_div) = 1) then
                        y(neg_div) <= '0';
                        end if;
                    if (y(neg_div) = 0) then
                        y(neg_div) <= '1';
                        end if;
                    end loop;
                
                alu_out <= "00000000";

                while to_integer(x) - to_integer(y) > -1 loop

                    count <= "00000001";
                    for div in 1 to to_integer(y) loop
                        x(0) <= x(0) XOR y(0);
                        x(0) <= x(0) AND y(0);
                        for div_ind in 0 to 6 loop
                            x(div_ind) <= (carry_out(div_ind) AND x(div_ind) AND y(div_ind)) 
                                             OR (NOT(carry_out(div_ind)) AND NOT(x(div_ind)) AND y(div_ind))
                                             OR (carry_out(div_ind) AND NOT(x(div_ind)) AND NOT(y(div_ind)))
                                             OR (carry_out(div_ind) AND x(div_ind) AND NOT(y(div_ind)));
                            carry_out(sub_ind+1) <= (carry_out(div_ind) AND x(div_ind))
                                             OR (carry_out(div_ind) AND y(div_ind))
                                             OR (x(div_ind) AND y(div_ind));
                            end loop;
                        end loop;
                    
                    alu_out(0) <= alu_out(0) XOR count(0);
                    count_carry(0) <= x(0) AND y(0);
                    for count_ind in 0 to 6 loop
                        alu_out(count_ind) <= (count_carry(count_ind) AND alu_out(count_ind) AND count(count_ind)) 
                                           OR (NOT(count_carry(count_ind)) AND NOT(alu_out(count_ind)) AND count(count_ind))
                                           OR (count_carry(count_ind) AND NOT(alu_out(count_ind)) AND NOT(count(count_ind)))
                                           OR (count_carry(count_ind) AND alu_out(count_ind) AND NOT(count(count_ind)));
                        count_carry(count_ind+1) <= (count_carry(count_ind) AND alu_out(count_ind))
                                           OR (count_carry(count_ind) AND count(count_ind))
                                           OR (alu_out(count_ind) AND count(count_ind));
                        end loop;
                    end loop;
        end case;
    end process;
end architecture;
