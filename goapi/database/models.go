package database

type Intensity struct {
	Id          string
	Name        string
	Description string
	Coefficient float64
}

type Workout struct {
	Id          string
	Name        string
	Description string
	Parts       []WorkoutPart
}

type WorkoutPart struct {
	Order     int
	Distance  int
	Metric    string
	Intensity Intensity
}

type Profile struct {
	Id        string
	FirstName string
	LastName  string
	Vdot      int
}

type Record struct {
	Id string
	Race string
	Duration string
}
