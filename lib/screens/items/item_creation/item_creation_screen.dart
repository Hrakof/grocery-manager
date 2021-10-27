import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:formz/formz.dart';
import 'package:grocery_manager/blogic/provider/items/item_creation/formz_inputs/inputs.dart';
import 'package:grocery_manager/blogic/provider/items/item_creation/item_creation_state.dart';
import 'package:grocery_manager/repositories/item/item_repository.dart';
import 'package:provider/provider.dart';

class ItemCreationScreen extends StatelessWidget {
  final String householdId;
  final ItemCollection itemCollection;

  const ItemCreationScreen({
    required this.householdId,
    required this.itemCollection,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.itemCreationTitle),
      ),
      body: ChangeNotifierProvider<ItemCreationState>(
        create: (context) => ItemCreationState(
            itemRepository: context.read<ItemRepository>(),
            householdId: householdId,
            itemCollection: itemCollection
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Flex(
              direction: Axis.vertical,
              children:const [Expanded(child: _ItemForm())]
          ),
        ),
      ),
    );
  }
}

class _ItemForm extends StatelessWidget {
  const _ItemForm({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;

    return SingleChildScrollView(
      child: Column(
        children: [
          const _NameInput(),
          const SizedBox(height: 8.0),
          ExpansionTile(
            title: Text(l10n.other),
            children: const [
              _AmountInput(),
              SizedBox(height: 8.0),
              _UnitInput(),
              SizedBox(height: 8.0),
              _DescriptionInput(),
            ],
          ),
          const SizedBox(height: 8.0,),
          const _CreateButton(),
        ],
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final Name name = context.select<ItemCreationState, Name>((state) => state.name);
    return TextField(
      onChanged: (value){ context.read<ItemCreationState>().changeName(value); },
      decoration: InputDecoration(
        icon: const Icon(Icons.description),
        labelText: l10n.nameLabel,
        helperText: '',
        errorText:  name.status == FormzInputStatus.pure ? null :
                    name.error == NameValidationError.tooShort ? l10n.tooShort :
                    null,
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final Amount amount = context.select<ItemCreationState, Amount>((state) => state.amount);
    return TextField(
      onChanged: (value){ context.read<ItemCreationState>().changeAmount(value); },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        icon: const Icon(Icons.pin),
        labelText: l10n.amountLabel,
        helperText: '',
        errorText:  amount.status == FormzInputStatus.pure ? null :
                    amount.error == AmountValidationError.notANumber ? l10n.notANumber :
                    amount.error == AmountValidationError.negative ? l10n.cantBeNegative :
                    null,
      ),
    );
  }
}

class _UnitInput extends StatelessWidget {
  const _UnitInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final Unit unit = context.select<ItemCreationState, Unit>((state) => state.unit);
    return TextField(
      onChanged: (value){ context.read<ItemCreationState>().changeUnit(value); },
      decoration: InputDecoration(
        icon: const Icon(Icons.point_of_sale),
        labelText: l10n.unitLabel,
        helperText: '',
        errorText:  unit.status == FormzInputStatus.pure ? null :
                    unit.error == UnitValidationError.tooLong ? l10n.tooLong :
                    null,
      ),
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  const _DescriptionInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final Description description = context.select<ItemCreationState, Description>((state) => state.description);
    return TextField(
      onChanged: (value){ context.read<ItemCreationState>().changeDescription(value); },
      decoration: InputDecoration(
        icon: const Icon(Icons.description),
        labelText: l10n.descriptionLabel,
        helperText: '',
        errorText:  description.status == FormzInputStatus.pure ? null :
                    description.error == DescriptionValidationError.tooLong ? l10n.tooLong :
                    null,
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final formStatus = context.select<ItemCreationState, FormzStatus>((state) => state.formStatus);
    final inProgress = context.select<ItemCreationState, bool>((state) => state.creationInProgress);

    if (inProgress){
      return const CircularProgressIndicator();
    }
    else{
      return ElevatedButton(
        onPressed: formStatus.isValid ? () async {
          final state = context.read<ItemCreationState>();
          if(state.creationInProgress){
            return;
          }
          await state.createItem();
          switch (state.creationResult){
            case ItemCreationResult.error:
              final snackBar = SnackBar(content: Text(l10n.createItemFailedMessage));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              break;
            case ItemCreationResult.success:
              Navigator.of(context).pop();
              break;
            default:
              break;
          }
        } : null,
        child: Text(l10n.createItemButtonText),
      );
    }
  }
}
