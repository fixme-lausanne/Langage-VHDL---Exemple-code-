-----------------------------------------------------------------------------------//
-- Nom du projet 		    : MIROIRE 
-- Nom du fichier 		    : compteur.vhd
-- Date de cr�ation 	    : 02.03.2017
-- Date de modification     : xx.xx.2017
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  �lectronique cr��e par l'ETML-ES, 
--							  r�alisation / simulation d'un message d�filant de type 
--							  A, b, c, d sur le premier segment � une fr�quence 20Hz.  
--
--							  Selon la configuration des switches S10 et S11, 
--							  le deuxi�me segment sera le miroire soit horizontal, soit 
--							  vertical du segment 1
--
--							  configuration SW10 et SW11
--							  S10 = 0 / S11 = 0 => il n'y a que le segment 1 qui est allum� 
--							  S10 = 0 / S11 = 1 => Segment 2 est le miroire horizontal du Segment 1  
--           				  S10 = 1 / S11 = 0 => Segment 2 est le miroire vertical du Segment 1 
--							  S10 = 1 / S11 = 1 => Segment 1 et 2 affiche le meme valeur  
--
--							      
-- Remarques 			    : lien
-- 							  1) https://fr.wikibooks.org/wiki/TD3_VHDL_Compteurs_et_registres
----------------------------------------------------------------------------------//
-- d�claration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;  
use ieee.numeric_std.all; 								-- pour les op�rations math�matiques et convertion 

-- d�claration de l'entit� (Entr�es / Sorties) --
entity COMPTEUR_ETAT is
	port(
		------------
		-- entr�e --
		------------ 
		-- logique -- 
		CLK 		: in std_logic; 		-- horloge a 1.8432 MHz 
		
		-- bus --
		CONSTANT_VAL_MAX : in std_logic_vector(0 to 3);  
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		BUS_NB_ETAT : out std_logic_vector(0 to 1)  -- retournera la nombre sous forme de bus logique 
	); 
END COMPTEUR_ETAT;

architecture COMP_COMPTEUR_ETAT of COMPTEUR_ETAT is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- constante -- 
	
	-- signaux -- 
	
	-- logique -- 
	
	-- entier -- 
	signal val_int, VAL_MAX : integer range 0 to 4 := 0; 
	
	
	begin 
		-------------------------------------------------------
		-- recuperation de la valeur max en valeur num�rique --
		-------------------------------------------------------
		VAL_MAX <= to_integer(unsigned(CONSTANT_VAL_MAX));

		------------------------------------------------------
		-- convertion de la valeur num�rique en bus logique --
		------------------------------------------------------
		BUS_NB_ETAT <= std_logic_vector(to_unsigned(val_int, 2)); 
		
		------------------------------------
		-- Selection des Etat de comptage --
		------------------------------------
		GESTION_ETAT: process (CLK)
			begin
				if rising_edge(CLK) then
					if(val_int <VAL_MAX ) then 
						val_int <= val_int + 1; 
					else  
						val_int <= 0; 
					end if; 
				end if;  
		end process; 

end COMP_COMPTEUR_ETAT; 