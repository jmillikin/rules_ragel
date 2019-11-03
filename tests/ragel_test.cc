#include <fstream>
#include <iostream>

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "tools/cpp/runfiles/runfiles.h"

using bazel::tools::cpp::runfiles::Runfiles;
using std::string;
using testing::HasSubstr;

#ifdef _WIN32
# define EXE ".exe"
#else
# define EXE ""
#endif

class RulesRagel : public ::testing::Test {
  protected:
    void SetUp() override {
        string error;
        runfiles_.reset(Runfiles::CreateForTest(&error));
        ASSERT_EQ(error, "");
    }

    string ReadFile(const string& path) {
        string resolved_path = runfiles_->Rlocation(path);
        std::ifstream fp(resolved_path, std::ios_base::binary);
        EXPECT_TRUE(fp.is_open());
        std::stringstream buf;
        buf << fp.rdbuf();
        return buf.str();
    }

    std::unique_ptr<Runfiles> runfiles_;
};

TEST_F(RulesRagel, GenruleCxx) {
    const auto parser_src = ReadFile("rules_ragel/tests/genrule_output.cc");
    ASSERT_THAT(parser_src, HasSubstr("static const int hello_world_start"));
}

TEST_F(RulesRagel, CompiledParserCxx) {
    const auto hello_cc_bin = ReadFile("rules_ragel/tests/hello_cc_bin" EXE);
    ASSERT_TRUE(hello_cc_bin.size() > 0);
}
