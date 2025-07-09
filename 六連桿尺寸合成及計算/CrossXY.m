function tau=CrossXY(Fx,Fy,Rx,Ry)
tau=cross([Rx Ry 0],[Fx Fy 0]);
tau=tau(3);
end