//header only
#pragma once
#include <vector>
#include "geometry_operators.cuh"
#include "primitives.cuh"
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
struct Face
{
	int a;
	int b;
	int c;
	Face() {};
	Face(int a, int b, int c)
	{
		this->a = a;
		this->b = b;
		this->c = c;
	}
};

struct Mesh_host
{
	std::vector<point> vertices;
	std::vector<Face> faces;
};

void parser_read(Mesh_host& mesh, std::string file_path)
{
	std::fstream file;
	file.open(file_path, std::ios::in);
	if (file.is_open())
	{
		std::string line;
		while (getline(file, line))
		{
			//vertices
			if (line[0] == 'v' && !(line[1] == 'n' || line[1] == 't'))
			{
				std::stringstream stream(line);
				std::vector<std::string> vals;
				std::string current;
				while (stream >> current)
				{
					if (current != "v")
						vals.push_back(current);
				}

				float x = std::stof(vals[0]);
				float y = std::stof(vals[1]);
				float z = std::stof(vals[2]);
				//std::cout << vals[0] << " " << vals[1] << " " << vals[2] << std::endl;
				mesh.vertices.push_back(point{ x,y,z });
			}
			//faces
			if (line[0] == 'f')
			{
				std::stringstream stream(line);
				std::vector<std::string> vals;
				std::string current;
				while (stream >> current)
				{
					if (current != "f")
						vals.push_back(current);
				}

				int vertex1 = std::stoi(vals[0]);
				int vertex2 = std::stoi(vals[1]);
				int vertex3 = std::stoi(vals[2]);
				//std::cout << vertex1 << " " << vertex2 << " " << vertex3 << std::endl;
				mesh.faces.push_back(Face{ vertex1 - 1, vertex2 - 1, vertex3 - 1 });
			}
		}
	}
	file.close();
}

std::vector<triangle> parser_mesh_to_triangles(const Mesh_host& mesh)
{
	std::vector<triangle> triangles;
	for (int i = 0; i < mesh.faces.size(); i++)
	{
		int a = mesh.faces[i].a;
		int b = mesh.faces[i].b;
		int c = mesh.faces[i].c;

		point vertex1 = mesh.vertices[a];
		point vertex2 = mesh.vertices[b];
		point vertex3 = mesh.vertices[c];


		triangles.push_back(triangle{ vertex1, vertex2, vertex3 });
	}
	return triangles;
}