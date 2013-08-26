function [stim,stimparam]=loadspeech2spect(n,fs);

fn=cell(30,1);
fn{1}='falk0';
fn{2}='falr0';
fn{3}='fcag0';
fn{4}='fcmm0';
fn{5}='feac0';
fn{6}='fgcs0';
fn{7}='fjkl0';
fn{8}='fjxp0';
fn{9}='flhd0';
fn{10}='fljd0';
fn{11}='fmmh0';
fn{12}='fntb0';
fn{13}='fpaz0';
fn{14}='fsak0';
fn{15}='fskl0';
fn{16}='maeb0';
fn{17}='mcdr0';
fn{18}='mdbp0';
fn{19}='mesg0';
fn{20}='mgrp0';
fn{21}='mjee0';
fn{22}='mjjj0';
fn{23}='mjpm1';
fn{24}='mjrh0';
fn{25}='mjws0';
fn{26}='mmdm0';
fn{27}='mprt0';
fn{28}='mrab1';
fn{29}='msms0';
fn{30}='mtrt0';

[y,fsin,nbits]=wavread([fn{n},'.wav']);

