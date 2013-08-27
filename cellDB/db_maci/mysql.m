%MYSQL - interface to an SQL database
%
%    MYSQL('open',HOST,USER,PASSWD,DB);
%    MYSQL('close');
%    [RESULT,AFFECTED,INSERTID]=MYSQL(QUERY);
%    Returns a structure with field names from query
%
%    [RESULT,AFFECTED,INSERTID]=MYSQL(QUERY,'fn');
%    Returns a structure with field names fn1, fn2, ...
%
%    [RESULT]=MYSQL(QUERY,'mat');
%    Returns a double matrix matching the query output.
%    It is a (recoverable) error to attempt this on non-numeric
%    databases.
%
%    See also: SQLINSERT

% NULL is returned as an empty double matrix.
%
% The following types will be returned as double:
% DECIMAL TINY SHORT LONG FLOAT DOUBLE LONGLONG INT24
%
% All BLOB types will be returned as uint8 vectors
%
% Other types will be returned as strings

% mysql_mex version 1.13
% 
% Authors:
% Kimmo Uutela, 1999 <Kimmo.Uutela@hut.fi>,
% John Fisher <jfisher@are.berkeley.edu>,
% Brian Shand <bshand@dip.ee.uct.ac.za>,
% Guido Dietz <Guido.Dietz@dlr.de>,
% and Hidai Kenichi <hidai@pdp.crl.sony.co.jp>
%
% http://boojum.hut.fi/~kuutela/mysqlmex.html
