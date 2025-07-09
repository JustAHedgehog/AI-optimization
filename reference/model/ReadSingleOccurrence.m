function OutMat=ReadSingleOccurrence(oOccurrence)
% 取得零件的逆變換矩陣
oInverseMatrix=oOccurrence.Transformation;
oInverseMatrix.Invert;
inverseMatrix=zeros(4,4); % 4x4 的零矩陣
for row=1:4
    for col=1:4
        inverseMatrix(row,col)=oInverseMatrix.Cell(row,col); % 提取矩陣元素
    end
end
% 取得零件的質量屬性
oMassProps=oOccurrence.MassProperties;
% 取得零件的文件
oPartDoc=oOccurrence.Definition.Document;
% 取得零件的零件號碼
oProperties=oPartDoc.PropertySets.Item("Design Tracking Properties");
PartNumber=oProperties.Item("Part Number").Value;
% 取得零件的料件號碼
% StockNumber=oProperties.Item("Stock Number").Value;
% 取得零件的材質屬性
oMaterial=oPartDoc.ActiveMaterial;

% 取得零件的名稱
OccurrenceName=oOccurrence.Name;
% 取得零件的轉動慣量
[Ixx,Iyy,Izz,Ixy,Iyz,Ixz]=oMassProps.XYZMomentsOfInertia();
% 取得零件的質心位置
oCenterOfMass=oMassProps.CenterOfMass;
CGx=oCenterOfMass.X;
CGy=oCenterOfMass.Y;
CGz=oCenterOfMass.Z;
% 將零件的質心位置轉換至零件本身的坐標系
CGmat=[CGx;CGy;CGz;1;];
CGmat=inverseMatrix*CGmat;
CGx=CGmat(1);
CGy=CGmat(2);
CGz=CGmat(3);
% 取得零件的質心位置的方位角
CGlength=sqrt(CGx^2+CGy^2);
CGang=atan2d(CGy,CGx);
if CGang<0
    CGang=CGang+360;
end
% 取得質量
mass=oMassProps.Mass;
% 取得材質的名稱
% materialName=oMaterial.Name;
% materialName=string(materialName);
% materialName=split(materialName);
% materialName=materialName(1);
materialName="密度7850的鋼";
% 取得材質的密度
density=oMassProps.Mass/oMassProps.Volume;
% 將零件的零件號碼更改為檔案名稱
oProperties.Item("Part Number").Value=oOccurrence.Name;
% 將零件數量級轉換正確
density=density*1e3; % kg/mm^3
CGx=CGx*1e1; % mm
CGy=CGy*1e1; % mm
CGz=CGz*1e1; % mm
CGlength=CGlength*1e1; % mm
Ixx=Ixx*1e2; % kg*mm^2
Iyy=Iyy*1e2; % kg*mm^2
Izz=Izz*1e2; % kg*mm^2
Ixy=Ixy*1e2; % kg*mm^2
Iyz=Iyz*1e2; % kg*mm^2
Ixz=Ixz*1e2; % kg*mm^2

density=round(density,6);
CGx=round(CGx,6);
CGy=round(CGy,6);
CGz=round(CGz,6);
CGlength=round(CGlength,6);
CGang=round(CGang,6);
Ixx=round(Ixx,6);
Iyy=round(Iyy,6);
Izz=round(Izz,6);
Ixy=round(Ixy,6);
Iyz=round(Iyz,6);
Ixz=round(Ixz,6);
fprintf("The part number is: %s \n",PartNumber);
fprintf("The part material name is: %s \n",materialName);
disp("--------------------------------------------------------------");
% 輸出所需參數
OutMat=[{PartNumber},mass,{materialName},density,CGx,CGy,CGz,CGlength,CGang,Ixx,Iyy,Izz,Ixy,Iyz,Ixz];
end