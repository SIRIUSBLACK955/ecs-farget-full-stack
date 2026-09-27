resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.1.0/24"
    tags = {
        Name = "public-subnet-1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.2.0/24"
    tags = {
        Name = "public-subnet-2"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id
}

resource "aws_internet_gateway_attachment" "igw_attachment" {
    vpc_id             = aws_vpc.name.id
    internet_gateway_id = aws_internet_gateway.igw.id
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.3.0/24"
    tags = {
        Name = "private-subnet-1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.4.0/24"
    tags = {
        Name = "private-subnet-2"
    }
}

resource "aws_subnet" "private_subnet_3" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.5.0/24"
    tags = {
        Name = "private-subnet-3"
    }
}

resource "aws_subnet" "private_subnet_4" {
    vpc_id            = aws_vpc.name.id
    cidr_block        = "10.0.6.0/24"
    tags = {
        Name = "private-subnet-4"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.name.id
    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route" "public_route" {
    route_table_id         = aws_route_table.public_route_table.id
    destination_cidr_block   = "0.0.0.0/0"
    gateway_id               = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
    subnet_id      = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_nat_gateway" "my_nat_gateway" {
    vpc_id = aws_vpc.my_vpc.id
    availability_mode = "regional"
    tags = {
        Name = "my_nat_gateway"
    }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.name.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
    }
    tags = {
        Name = "private-route-table"
    }
}

resource "aws_route_table_association" "private_subnet_1_association" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_3_association" {
    subnet_id      = aws_subnet.private_subnet_3.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_4_association" {
    subnet_id      = aws_subnet.private_subnet_4.id
    route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "alb-sg" {
    name        = "alb-sg"
    description = "Allow HTTP and HTTPS traffic"
    vpc_id      = aws_vpc.name.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "frontend-sg" {
    name        = "frontend-sg"
    description = "Allow traffic from ALB"
    vpc_id      = aws_vpc.name.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb-sg.id]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [aws_security_group.alb-sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "backend-sg" {
    name        = "backend-sg"
    description = "Allow traffic from frontend"
    vpc_id      = aws_vpc.name.id

    ingress {
        from_port   = 5000
        to_port     = 5000
        protocol    = "tcp"
        security_groups = [aws_security_group.alb-sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "database-sg" {
    name        = "database-sg"
    description = "Allow traffic from backend"
    vpc_id      = aws_vpc.name.id

    ingress {
        from_port   = 5432
        to_port     = 5432
        protocol    = "tcp"
        security_groups = [aws_security_group.backend-sg.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
    name       = "my-db-subnet-group"
    subnet_ids = [ aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]
}

resource "aws_db_instance" "my_database" {
    allocated_storage    = 20
    engine               = "postgres"
    engine_version       = "12.4"
    instance_class       = "db.t3.micro"
    identifier           = "cloud-notes-db"
    db_name              = "cloudnotes"
    username             = "appuser"
    password             = "Cloud123"
    parameter_group_name = "default.postgres12"
    skip_final_snapshot  = true
    vpc_security_group_ids = [aws_security_group.database-sg.id]
    db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
    publicly_accessible    = false
}
