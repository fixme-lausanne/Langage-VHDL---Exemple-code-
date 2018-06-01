-----------------------------------------------------------------------------------//
-- Nom du projet 		    : COMPTEUR_BONNE_ANNEE 
-- Nom du fichier 		    : div_frequence.vhd
-- Date de création 	    : 25.01.2018
-- Date de modification     : xx.xx.2017
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  électronique créée par l'ETML-ES, 
--							  réalisation / simulation 
-- 							  diviseur de fréquence générique - on recoit la 
--							  fréquence de base / le nb de tic max et on créer 
--							  le signal de la nouvelle clock 
--							      
-- Remarques 			    : lien
-- 							  1) https://fr.wikibooks.org/wiki/TD3_VHDL_Compteurs_et_registres
----------------------------------------------------------------------------------//
-- déclaration standart des librairies standart pour le VHDL -- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;  
use ieee.numeric_std.all; 								-- pour les opérations mathématiques et convertion 

-- déclaration de l'entité (Entrées / Sorties) --
entity DIV_FREQ is
	port(
		------------
		-- entrée --
		------------ 
		-- logique -- 
		CLK_IN 		: in std_logic; 						-- horloge a 1.8432 MHz 
		
		-- bus --
		BUS_VAL_TIC 	: in std_logic_vector(0 to 23); 
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		CLK_OUT	: out std_logic;  
		
		----------------------------------------------------
		-- Elément uniquement utiliser pour la simulation --
		----------------------------------------------------
		clk_SIM  : out std_logic
	); 
END DIV_FREQ;

architecture COMP_DIV_F of DIV_FREQ is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- constantes -- 
	
	-- signaux -- 
	-- logique --

	-- bus --
	
	-- entier -- 			
	signal nb_tic, cpt_p_1HZ, cpt_f_1HZ	:	integer;  	--: std_logic_vector(0 to 23);

	begin 

	-------------------------------------------------------
	-- recuperation de la valeur max en valeur numérique --
	-------------------------------------------------------
	nb_tic <= to_integer(unsigned(BUS_VAL_TIC));

	----------------------------------
	-- compteur tic horloge systeme -- 
	----------------------------------	
	CMPT_ETAT_PRESENT : process(CLK_IN)
		begin 
			-- MAJ de tous du compteur => Etat P prend Etat F -- 
			if ((CLK_IN'event) and (CLK_IN = '1')) then 
				cpt_p_1HZ <= cpt_f_1HZ; 
			end if; 
	end process; 
	
	CMPT_ETAT_FUTUR_1HZ : process(cpt_p_1HZ)
		begin 
			if (cpt_p_1HZ >= nb_tic) then
				cpt_f_1HZ <= 0; --(others => 0);				-- remise à 0 
			else 
				cpt_f_1HZ <= cpt_p_1HZ + 1;  				-- incrémentation 
			end if; 
	end process; 
	
	-------------------------------------
	-- Horloge rapport cyclique de 50% -- 
	-------------------------------------
	CLK_1HZ_50P : process (CLK_IN)
		begin 
			-- synchronisation sur la clock pour éviter des effets -- 
			if rising_edge(CLK_IN) then 
				if (cpt_p_1HZ <= (nb_tic/2)) then 
					CLK_OUT <= '0'; 
				else 
					CLK_OUT <= '1';
				end if; 
			end if; 
	end process; 


end architecture; 
	



