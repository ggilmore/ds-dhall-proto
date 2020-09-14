let ContainerResources = { CPU : Double, Memory : Text }

let Container = { Requests : ContainerResources }

in  { Requests = { CPU : 2.0, Memory : "4g" } } : Container
