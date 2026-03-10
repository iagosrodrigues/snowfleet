_: {
  flake.modules.homeManager.git = _: {
    programs.git = {
      enable = true;

      settings = {
        alias = {
          br = "branch";
          ci = "commit";
          cl = "clone";
          co = "switch";
          cob = "switch -c";
          cp = "cherry-pick";
          cs = "commit -S";
          gr = "grep -Ii";
          r = "reset";
          s = "status -s";
          ss = "status";
          ai = "add --interactive";
          diff = "diff --ignore-space-at-eol -b -w --ignore-blank-lines";
          f = "!git ls-files | grep -i";
          grep = "grep -Ii";
          cm = "commit -m";
          cma = "commit -a -m";
          ca = "commit --amend";
          caa = "commit -a --amend -C HEAD";
          fl = "log -u";
          l = "log --graph --pretty=format:'%Cred%h%Creset %G? %C(bold blue)%an%C(reset) - %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
          ll = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [a:%an,c:%cn]' --decorate --numstat";
          lnc = "log --pretty=format:'%h %s [%cn]'";
          ls = "log --pretty=format:'%C(green)%h %C(yellow)[%ad]%Cred%d %Creset%s%Cblue [%an]' --decorate --date=relative";
          d = "diff";
          dl = "-c diff.external=difft log -p --ext-diff";
          ds = "-c diff.external=difft show --ext-diff";
          dft = "-c diff.external=difft diff";
          dw = "diff --word-diff";
          dc = "diff --cached";
          dlc = "diff --cached HEAD^";
          dt = "difftool";
          sl = "stash list";
          sa = "stash apply";
          sp = "stash pop";
          assume = "update-index --assume-unchanged";
          assumeall = "!git status -s | awk {'print $2'} | xargs git assume";
          assumed = "!git ls-files -v | grep ^h | cut -c 3-";
          unassume = "update-index --no-assume-unchanged";
          unassumeall = "!git assumed | xargs git unassume";
          sba = "!f() { git subtree add --prefix $2 $1 master --squash; }; f";
          sbu = "!f() { git subtree pull --prefix $2 $1 master --squash; }; f";
          si = "submodule init";
          su = "submodule update --remote";
          sub = "!git submodule sync && git submodule update";
          first = "rev-list --max-parents=0 HEAD";
          count = "rev-list --count HEAD";
          expire = "reflog expire --expire=now --all && git gc --prune=now --aggressive";
          cleanup = "!git remote prune origin && git gc && git clean -df && git stash clear";
          conf = "!git s | grep ^U";
          cont = "rebase --continue";
          day = "!sh -c 'git log --reverse --no-merges --branches=* --date=local --after=\"yesterday 11:59PM\" --author=\"`git config --get user.name`\"'";
          empty = "!git commit -am\"[empty] Initial commit\" --allow-empty";
          la = "!git config -l | grep alias | cut -c 7-";
          lasttag = "describe --tags --abbrev=0";
          ours = "!f() { git co --ours $@ && git add $@; }; f";
          review = "!git log --no-merges --pretty=%an | head -n 100 | sort | uniq -c | sort -nr";
          theirs = "!f() { git co --theirs $@ && git add $@; }; f";
          unstage = "!git reset";
          update = "!git fetch upstream && git rebase upstream/`git rev-parse --abbrev-ref HEAD`";
          churn = "!f() { git log --all -M -C --name-only --format='format:' \"$@\" | sort | grep -v '^$' | uniq -c | sort | awk 'BEGIN {print \"count\\tfile\"} {print $1 \"\\t\" $2}' | sort -g; }; f";
          forget = "!git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D";
        };

        init.defaultBranch = "master";

        core = {
          editor = "nvim";
          whitespace = "cr-at-eol";
          ignoreCase = false;
          useBuiltinFSMonitor = true;
          untrackedcache = true;
          autocrlf = "input";
          excludesfile = "~/.gitignore_global";
        };

        protocol.version = "2";
        fetch.writeCommitGraph = true;
        rerere.enabled = true;

        grep = {
          extendRegexp = true;
          lineNumber = true;
        };

        rebase = {
          instructionFormat = "[%an - %ar] %s";
          autosquash = true;
        };

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        pull.default = "current";

        branch.sort = "-committerdate";

        apply.whitespace = "nowarn";

        commit = {
          template = "~/.gitmessage";
          gpgsign = true;
        };

        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };

        mergetool."vimdiff".cmd = "nvim -d $LOCAL $REMOTE $MERGED -c 'wincmd w' -c 'wincmd L'";
        mergetool.prompt = true;

        diff = {
          renames = "copies";
          mnemonicprefix = true;
          compactionHeuristic = true;
          tool = "vimdiff";
          colorMoved = "default";
        };

        difftool."vimdiff".cmd = "nvim -d $LOCAL $REMOTE -c 'wincmd w' -c 'wincmd L'";
        difftool.prompt = false;

        interactive.diffFilter = "delta --color-only --features=interactive";

        delta = {
          navigate = true;
          features = "decorations";
          light = false;
        };

        delta."interactive"."keep-plus-minus-markers" = false;

        delta."decorations" = {
          "commit-decoration-style" = "blue ol";
          "commit-style" = "raw";
          "file-style" = "omit";
          "hunk-header-decoration-style" = "blue box";
          "hunk-header-file-style" = "red";
          "hunk-header-line-number-style" = "#067a00";
          "hunk-header-style" = "file line-number syntax";
        };
        color = {
          "branch" = {
            current = "green bold";
            local = "green";
            remote = "red bold";
          };

          "diff" = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
          };

          "status" = {
            added = "green bold";
            changed = "yellow bold";
            untracked = "white";
            deleted = "red bold";
          };
        };

        filter."lfs" = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };

        column.ui = "auto";
        gitsh.defaultCommand = "s";
      };
    };
  };
}
