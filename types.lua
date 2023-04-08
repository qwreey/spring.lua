export type spring = {
	Mass: number;
	Damping: number;
	Constant: number;
	InitialOffset: number;
	InitialVelocity: number;
	ExternalForce: number;

	GetOffset: (self:spring)->number;
	GetVelocity: (self:spring)->number;
	GetAcceleration: (self:spring)->number;
	GetGoal: (self:spring)->number;

	SetExternalForce: (self:spring,force:number)->();
	SetGoal: (self:spring,goal:number)->();
	AddOffset: (self:spring,offset:number)->();
	AddVelocity: (self:spring,velocity:number)->();
	SetOffset: (self:spring,offset:number)->number;
	InitResolver: (self:spring)->spring;
}
export type springIniter = {
	New: (Mass:number,Damping:number,Constant:number,InitialOffset:number,InitialVelocity:number,ExternalForce:number)->spring
}
return {}
