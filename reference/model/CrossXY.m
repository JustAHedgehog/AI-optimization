function tau=CrossXY(Fx,Fy,Rx,Ry)
%{ cross product in force vector & position vector}%
    tau=cross([Rx Ry 0],[Fx Fy 0]);
    tau=tau(3);
end