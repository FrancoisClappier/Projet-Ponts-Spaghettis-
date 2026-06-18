function  [JointNo,ElementNo,xJoint,yJoint,XR,YR,FX,BJ,EJ,E,A,FY,zJoint,ZR,FZ]=RemovedNan(JointNo,ElementNo,xJoint,yJoint,XR,YR,FX,BJ,EJ,E,A,FY,zJoint,ZR,FZ)
JointNo = rmmissing(JointNo);
xJoint=rmmissing(xJoint);
yJoint=rmmissing(yJoint);
zJoint=rmmissing(zJoint);
XR=rmmissing(XR);
YR=rmmissing(YR);
ZR=rmmissing(ZR);
FX=rmmissing(FX);
FY=rmmissing(FY);
FZ=rmmissing(FZ);
ElementNo=rmmissing(ElementNo);
BJ=rmmissing(BJ);
EJ=rmmissing(EJ);
E=rmmissing(E);
A=rmmissing(A);
end