-----------------------------------------------------------------------------------//
-- Nom du projet 		    : MIROIR 
-- Nom du fichier 		    : main_miroire.vhd
-- Date de cr�ation 	    : 28.02.2017
-- Date de modification     : xx.xx.2017
--
-- Auteur 				    : Philou (Ph. Bovey)
--
-- Description              : A l'aide d'une FPGA (EMP1270T144C5) et d'une carte 
--							  �lectronique cr��e par l'ETML-ES, 
--							  r�alisation / simulation d'un message d�filant de type 
--							  A, b, c, d sur le premier segment � une fr�quence 10Hz.  
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
entity MIROIRE is
	port(
		------------
		-- entr�e --
		------------ 
		-- logique -- 
		CLK_1_8MHZ 		: in std_logic; 		-- horloge a 1.8432 MHz 
		SW_10, SW_11 	: in std_logic; 		-- switch 1, 2, 10, 11
		-- bus --
		
		------------
		-- sortie --
		------------
		-- logique --
		
		-- bus --
		SEGMENTS_1 : out std_logic_vector(0 to 6); 		-- Affichage 7Seg -> ABCDEFG 
		SEGMENTS_2 : out std_logic_vector(0 to 6); 		-- Affichage 7Seg -> ABCDEFG
		
		----------------------------------------------------
		-- El�ment uniquement utiliser pour la simulation --
		----------------------------------------------------
		clk_2KHz_SIM  : out std_logic
	); 
END MIROIRE;

architecture COMP_MIROIRE of MIROIRE is 
	----------------------
	-- signaux internes -- 
	----------------------
	-- constant -- 
	constant VAL_MAX_COMPTEUR 	     		: std_logic_vector(0 to 19) := X"59FFF";   	-- Valeur r�el : 368640 - 1 	-> 59FFF (19)  
	constant VAL_MAX_COMPTEUR_DIV2 	    	: std_logic_vector(0 to 19) := X"2CFFF";   	-- Valeur r�el : 184320 - 1 	-> 2CFFF (19)  
	constant VAL_MAX_COMPTEUR_ETAT			: std_logic_vector(0 to 3)  := X"4"; 

	-- signaux -- 
	-- logique --
	signal clk_int 	: std_logic; 
	
	signal S,A,B,C	: std_logic; 
	
	-- bus -- 
	signal cpt_clk_p, cpt_clk_f 				: std_logic_vector(0 to 19);
	signal bus_int_ETAT_SEG1, bus_cmpt_etat 	: std_logic_vector(0 to 1); 	 -- bus sp�cifique pour l'affichage du SEGMENT1, 
																			     -- bus pour logique pour les diff�rents etat
	
	-- composant -- 
	component AFF_7SEG is
		port(
				------------
				-- entr�e --
				------------ 
				INFO_ETAT	: in std_logic_vector(0 to 1); 		-- d�fini quel tableau lire 
				INFO_CMPT	: in std_logic_vector(0 to 1); 		-- d�fini quel segment d'un tableau lire
		
				------------
				-- sortie --
				------------
				VAL_SEG : out std_logic_vector(0 to 6) 		-- Affichage 7Seg -> ABCDEFG 
			); 
	END component;
		
	component COMPTEUR_ETAT is
		port(
			------------
			-- entr�e --
			------------ 
			CLK 		: in std_logic; 		
			CONSTANT_VAL_MAX : in std_logic_vector(0 to 3);  
		
			------------
			-- sortie --
			------------
			BUS_NB_ETAT : out std_logic_vector(0 to 1)  -- retournera la nombre sous forme de bus logique 
		); 
	end component; 
	
	---------------------
	-- d�but programme --
	---------------------
	begin 
	
	S <= (A and (B or C)) XOR (not(C and B) or A); 
	S <= (A and (B or C)) XOR ((not(C) and not(B)) or A); 
	
	-------------------------------
	-- creation d'un bus interne --
	-------------------------------
	bus_int_ETAT_SEG1 <= "11";  
	                              
	----------------------------------
	-- compteur tic horloge systeme -- 
	----------------------------------
	CMPT_ETAT_PRESENT : process(CLK_1_8MHZ)
		begin 
			-- MAJ de tous les compteur -- 
			if ((CLK_1_8MHZ'event) and (CLK_1_8MHZ = '1')) then 
				cpt_clk_p <= cpt_clk_f;
			end if; 
	end process; 

	CMPT_ETAT_FUTUR : process(cpt_clk_p)
		begin 
			if (cpt_clk_p >= VAL_MAX_COMPTEUR) then
				cpt_clk_f <= (others => '0');				-- remise � 0 
			else 
				cpt_clk_f <= cpt_clk_p + 1;  				-- incr�mentation 
			end if; 
	end process; 
	
	-------------------------------------
	-- Horloge rapport cyclique de 50% -- 
	-------------------------------------
	CLK_INT_50P : process (CLK_1_8MHZ)
		begin 
			-- synchronisation sur la clock pour �viter des effets -- 
			if rising_edge(CLK_1_8MHZ) then 
				if (cpt_clk_p <= VAL_MAX_COMPTEUR_DIV2) then 
					clk_int <= '0'; 
				else 
					clk_int <= '1';
				end if; 
			end if; 
	end process; 
	
	-------------------------------------
	-- gestion du compteur d'affichage -- 
	-------------------------------------
	COMPTEUR_AFF : COMPTEUR_ETAT port map (CLK => clk_int,
										   CONSTANT_VAL_MAX => VAL_MAX_COMPTEUR_ETAT,
										   BUS_NB_ETAT => bus_cmpt_etat); 
	
	
	--------------------------------------------
	-- gestion des affichages par composanrts --
	--------------------------------------------
	-- segment 1 -- 
	AFF_SEG1 : AFF_7SEG port map (INFO_ETAT => bus_int_ETAT_SEG1,
	                              INFO_CMPT => bus_cmpt_etat, 
	                              VAL_SEG => SEGMENTS_1); 
	
	-- segment 2 -- 
	AFF_SEG2 : AFF_7SEG port map (INFO_ETAT => (SW_10, SW_11),
	                              INFO_CMPT => bus_cmpt_etat,  
	                              VAL_SEG => SEGMENTS_2); 

end COMP_MIROIRE; 