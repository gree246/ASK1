#include <iostream>
#include <fstream>
#include <cstring>
#include <cstdlib>
#include <istream>
using namespace std;

struct user
{
	string login;
	string haslo;
	int dobrze;
	int zle;
	int* zadania;
};

struct baza
{
	string nazwa;


};

bool init(user user1, baza baza1) {

	string nazwa;
	cout << "Podaj login:\n";
	cin >> nazwa;
	nazwa += ".txt";
	fstream uzytkownik;
	uzytkownik.open(nazwa.c_str(), ios::in | ios::out);
	if (uzytkownik.is_open() == false)
	{
		cout << "Nie ma takiego uzytkownika \n";
		system("pause");
		system("cls");
		return init(user1, baza1);
	}


	getline(uzytkownik, user1.login);
	getline(uzytkownik, user1.haslo);
	string haslo;
	cout << "Podaj haslo:\n";
	cin >> haslo;
	if (haslo != user1.haslo)
	{
		cout << "Bledne haslo \n";
		system("pause");
		uzytkownik.close();
		system("cls");
		return init(user1, baza1);
	}
	string lekcja;
	cout << "Podaj nazwe lekcji: \n";
	cin >> lekcja;

	string buf;
	while (getline(uzytkownik, buf)) {


		bool n = false;
		string baza1;
		int i = 0;

		while (buf[i] != (int)';')
		{
			baza1 += buf[i];
			i++;
		}
		if (baza1 != lekcja) {
			continue;
		}

		string tmp;
		tmp += buf[i + 1];
		tmp += buf[i + 2];
		tmp += buf[i + 3];
		user1.dobrze = atoi(tmp.c_str());
		i += 3;
		tmp = "";
		tmp += buf[i + 1];
		tmp += buf[i + 2];
		tmp += buf[i + 3];
		user1.zle = atoi(tmp.c_str());
		i += 3;
		int wymiar = buf.size();
		user1.zadania = new int[(wymiar - i) / 2];
		for (int j = 0; j<(wymiar - i) / 2; j++)
		{
			tmp = "";
			tmp += buf[2 * j + i + 1];
			tmp += buf[2 * j + i + 2];
			user1.zadania[j] = atoi(tmp.c_str());
		}

		uzytkownik.close();
		return true;


	}
	cout << "Nie znaleziono pliku \n";
	system("pause");
	system("cls");
	return false;

}
void menu(user user1, baza baza1);
bool graj(user user1, baza baza1);


void menu(user user1, baza baza1) {
	system("cls");


}

bool graj(user user1, baza baza1)
{

}

int main()
{
	user user1;
	baza baza1;

	if (!init(user1, baza1)) {
		return 0;
	}





	//	for (int j = 0; j < (wymiar - i) / 2; j++) {
	//		cout << user1.zadania[j] << "  ";
	//	}

	cout << user1.dobrze << "     " << user1.zle;
	return 0;
}
