<?php

namespace Zerotoprod\Zerotoprod\Acli\Src;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

/**
 * Project source link
 *
 * @link https://github.com/zero-to-prod/acli
 */
#[AsCommand(
    name: SrcCommand::signature,
    description: 'Project source link'
)]
class SrcCommand extends Command
{
    /**
     * @link https://github.com/zero-to-prod/acli
     */
    public const signature = 'acli:src';

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $output->writeln('https://github.com/zero-to-prod/acli');

        return Command::SUCCESS;
    }
}